import UIKit
import StandardCyborgFusion

final class ScanningInteractor {
    
    // MARK: - variables
    
    private var filesToExport: Set<FeetFile> = []
    private var imagesToExport: Set<FeetFile> = []
    
    // MARK: - gui

    private lazy var fileHelper = FileHelper()
    
    // MARK: - actions
    
    func clear() {
        self.filesToExport.removeAll()
        self.imagesToExport.removeAll()
    }
    
    func saveSceneAndImage(_ sceneModel: SceneModel, foot: FootSideType, completion: @escaping (() -> Void)) {
        /// scene should be created here, because using the copy lead to problem in presentation of model
        self.fileHelper.saveSceneAndImage(scene: SCScene(pointCloud: sceneModel.pointCloud,
                                                         mesh: sceneModel.mesh),
                                          imageData: sceneModel.photoImageData,
                                          footType: foot) { [weak self] (filePath, imagePath) in
            guard let self = self else { return }
            
            if let fileToExport = self.fileHelper.getDataFile(path: filePath) {
                self.filesToExport.insert(fileToExport)
            }
            
            if let imageToExport = self.fileHelper.getDataFile(path: imagePath) {
                self.imagesToExport.insert(imageToExport)
            }
            
            completion()
        }
    }
    
    func exportFiles() {
        var filesToExport = self.filesToExport.map({ $0.fileName })
        filesToExport += self.imagesToExport.map({ $0.fileName })
        self.fileHelper.export(paths: filesToExport)
    }
}
