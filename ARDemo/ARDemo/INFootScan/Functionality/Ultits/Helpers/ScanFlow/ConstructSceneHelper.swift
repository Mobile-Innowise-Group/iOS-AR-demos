import SceneKit
import StandardCyborgFusion
import CoreML

final class ConstructSceneHelper: NSObject {
    
    // MARK: - properties
    
    var assimilatedFrameIndex = 0
    var latestViewMatrix = matrix_identity_float4x4
    var state: ScanningViewControllerState = .default
    
    private let texturedMeshColorBufferSaveInterval: Int = 20
    private let failedScanShowPreviewMinFrameCount = 50
    private let maxReconstructionThreadCount: Int32 = 2
    
    private let resetSessionAction: () -> Void
    private let stopScanningAction: (ScanningTerminationReason) -> Void
    
    // MARK: - logic variables
    
    ///PointCloudCommandEncoder -> updateSharedUniformsBuffer -> - change distance of metal model 
    private var meshingHelper: SCMeshingHelper?
    private(set) var scanningViewRenderer: ScanningViewRenderer?
    private(set) var reconstructionManager: SCReconstructionManager?
    private(set) lazy var meshTexturing: SCMeshTexturing = .init()
    private lazy var containerNode: SCNNode = .init()
    
    // MARK: - initialization
    
    init(metalDevice: MTLDevice?,
         resetSessionAction: @escaping () -> Void,
         stopScanningAction: @escaping (ScanningTerminationReason) -> Void) {
        self.resetSessionAction = resetSessionAction
        self.stopScanningAction = stopScanningAction
        super.init()
        
        guard let metalDevice = metalDevice,
              let commandQueue = metalDevice.makeCommandQueue() else { return }
        
        self.reconstructionManager = SCReconstructionManager(
            device: metalDevice,
            commandQueue: commandQueue,
            maxThreadCount: self.maxReconstructionThreadCount)
        /// used for creation visual mesh model on the screen
        self.scanningViewRenderer = DefaultScanningViewRenderer(device: metalDevice,
                                                                commandQueue: commandQueue)
        self.setConfigurations()
    }
    
    // MARK: - configuration
    
    private func setConfigurations() {
        self.reconstructionManager?.delegate = self
        self.reconstructionManager?.includesColorBuffersInMetadata = true
    }
    
    // MARK: - actions
    
    func completionRenderingAction(successHandler: @escaping (_ pointCloud: SCPointCloud, _ mesh: SCMesh) -> Void) {
        guard let reconstructionManager = self.reconstructionManager else { return }
        self.meshTexturing.cameraCalibrationData = reconstructionManager.latestCameraCalibrationData
        self.meshTexturing.cameraCalibrationFrameWidth = reconstructionManager.latestCameraCalibrationFrameWidth
        self.meshTexturing.cameraCalibrationFrameHeight = reconstructionManager.latestCameraCalibrationFrameHeight
        
        // Do final cleanup on the scan
        reconstructionManager.finalize {
            let pointCloud = reconstructionManager.buildPointCloud()
            
            // Reset it now to keep peak memory usage down
            reconstructionManager.reset()
            
            self.constructScene(withSCScene: SCScene(pointCloud: pointCloud, mesh: nil)) { [weak self] scene in
                guard let scene = scene else {
                    self?.resetSessionAction()
                    return
                }

                /// Somehow resolve thread problem issue.
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    successHandler(scene.pointCloud, scene.mesh)
                }
            }
        }
    }
    
    /// constructing scene by rendered mesh
    private func constructScene(withSCScene scScene: SCScene,
                                completion: @escaping ((pointCloud: SCPointCloud, mesh: SCMesh)?) -> Void ) {
        self.containerNode.addChildNode(scScene.rootNode)
        if let pointCloud = scScene.pointCloud,
            self.containerNode.childNode(withName: "SCMesh", recursively: true) == nil {
            DispatchQueue.global().async { [weak self] in
                guard let self = self else { return }
                self.processMeshTexturingIntoMesh(withPointCloud: pointCloud,
                                                  meshTexturing: self.meshTexturing) { result in
                    switch result {
                    case .success(let mesh):
                        DispatchQueue.main.async { completion((pointCloud, mesh)) }
                    case .failure(let error):
                        print("Error processing mesh: \(String(describing: error.localizedDescription))")
                        DispatchQueue.main.async { completion(nil) }
                    }
                }
            }
        }
    }
    
    /// rendering your mesh from depth data
    private func processMeshTexturingIntoMesh(withPointCloud pointCloud: SCPointCloud,
                                              meshTexturing: SCMeshTexturing,
                                              completion: @escaping ((Result<SCMesh, Error>) -> Void)) {
        self.meshingHelper = SCMeshingHelper(pointCloud: pointCloud, meshTexturing: meshTexturing)
        self.meshingHelper?.processMesh { meshingStatus in
            DispatchQueue.main.async {
                switch meshingStatus {
                case .failure(let error):
                    completion(.failure(error))
                case .success(let mesh):
                    completion(.success(mesh))
                case .inProgress(_):
                    break
                }
            }
        }
    }
    
    // MARK: - reset
    
    func reset() {
        self.reconstructionManager?.reset()
        self.meshTexturing.reset()
    }
}

// MARK: - SCReconstructionManagerDelegate
extension ConstructSceneHelper: SCReconstructionManagerDelegate {
    
    /// saving what depth data camera seen
    func reconstructionManager(_ manager: SCReconstructionManager,
                               didProcessWith metadata: SCAssimilatedFrameMetadata,
                               statistics: SCReconstructionManagerStatistics) {
        guard self.state == .scanning else { return }
        self.latestViewMatrix = metadata.viewMatrix
        
        switch metadata.result {
        case .succeeded, .poorTracking:
            if self.assimilatedFrameIndex % self.texturedMeshColorBufferSaveInterval == 0,
               let colorBuffer = metadata.colorBuffer?.takeUnretainedValue() {
                self.meshTexturing.saveColorBufferForReconstruction(colorBuffer,
                                                                    withViewMatrix: metadata.viewMatrix,
                                                                    projectionMatrix: metadata.projectionMatrix)
            }
            self.assimilatedFrameIndex += 1
        case .failed:
            let assimilatedTooFewFrames = statistics.succeededCount < self.failedScanShowPreviewMinFrameCount
            self.stopScanningAction(assimilatedTooFewFrames ? .canceled : .finished)
            self.resetSessionAction()
        case .lostTracking:
            break
        @unknown default:
            break
        }
    }
    
    func reconstructionManager(_ manager: SCReconstructionManager, didEncounterAPIError error: Error) {
        print("SCReconstructionManager hit API error: \(error)")
        self.resetSessionAction()
    }
}
