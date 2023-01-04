/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A visualization of a detected object, using either a loaded 3D asset or a simple bounding box.
*/

import Foundation
import ARKit
import SceneKit

class DetectedObject: SCNNode {
    private lazy var bootNode: SCNNode = {
        try! SCNScene(
            url: Bundle.main.url(
                forResource: "Nike_Air_Jordan_Jordan",
                withExtension: "scn"
            )!
        ).rootNode.childNodes.first!
    }()

    var displayDuration: TimeInterval = 1.0 // How long this visualization is displayed in seconds after an update
    
    private var detectedObjectVisualizationTimer: Timer?
    
    private let pointCloudVisualization: DetectedPointCloud
    
    private var boundingBox: DetectedBoundingBox?
    
    private var originVis: SCNNode
    private var customModel: SCNNode?
    
    private let referenceObject: ARReferenceObject
    
    func set3DModel(_ url: URL?) {
        if let url = url, let model = load3DModel(from: url) {
            customModel?.removeFromParentNode()
            customModel = nil
            originVis.removeFromParentNode()
            ViewController.instance?.sceneView.prepare([model], completionHandler: { _ in
                self.addChildNode(model)
            })
            customModel = model
            pointCloudVisualization.isHidden = true
            boundingBox?.isHidden = true
        } else {
            customModel?.removeFromParentNode()
            customModel = nil
            addChildNode(originVis)
            pointCloudVisualization.isHidden = false
            boundingBox?.isHidden = false
        }
    }
    
    init(referenceObject: ARReferenceObject) {
        self.referenceObject = referenceObject
        pointCloudVisualization = DetectedPointCloud(referenceObjectPointCloud: referenceObject.rawFeaturePoints,
                                                     center: referenceObject.center, extent: referenceObject.extent)
        
        if let scene = SCNScene(named: "axes.scn", inDirectory: "art.scnassets") {
            originVis = SCNNode()
            for child in scene.rootNode.childNodes {
                originVis.addChildNode(child)
            }
//            if let bootScene = SCNScene(named: "converse_obj.scn") {
//                bootScene.rootNode.childNode(withName: "default", recursively: true)
//                    .flatMap { [originVis] node in
//                        node.position = .init(0.0, 0.0, 40.0)
//                        originVis.addChildNode(node)
//                    }
////                bootScene.rootNode.childNodes.forEach(originVis.addChildNode(_:))
//            }

//            let text = SCNText(string: "SIZE OF THIS OBJECT IS...",
//                               extrusionDepth: 0.05)
//
//            text.flatness = 0.5
//            text.font = UIFont.boldSystemFont(ofSize: 10)
//
//            let textNode = SCNNode(geometry: text)
//            textNode.geometry?.firstMaterial?.diffuse.contents = UIColor.white
//            textNode.scale = SCNVector3(0.01, 0.01, 0.01)

//            originVis.addChildNode(textNode)
        } else {
            originVis = SCNNode()
            print("Error: Coordinate system visualization missing.")
        }
        
        super.init()
        addChildNode(pointCloudVisualization)
        isHidden = true
        
        set3DModel(ViewController.instance?.modelURL)
        originVis.addChildNode(bootNode)
        let extent = referenceObject.extent
        bootNode.simdTransform = .init(
            .init(0.1, 0.0, 0.0, 0.0),
            .init(0.0, 0.1, 0.0, 0.0),
            .init(0.0, 0.0, 0.1, 0.0),
            .init(0.0, 0.0, 0.0, 1.0)
        )
//        * .init(
//            .init(1.0, 0.0, 0.0, 0.0),
//            .init(0.0, 1.0, 0.0, 0.0),
//            .init(0.0, 0.0, 1.0, 0.0),
//            .init(0.0, 0.0, 0.0, 1.0)
//        )
//        * .init(
//            .init(0.0, 0.0, 0.0, 100.0),
//            .init(0.0, 0.0, 0.0, 0.0),
//            .init(0.0, 0.0, 0.0, 0.0),
//            .init(0.0, 0.0, 0.0, 1.0)
//        )
        bootNode.simdWorldTransform = .init(
            .init(0.01, 0.0, 0.0, 0.0),
            .init(0.0, 0.01, 0.0, 0.0),
            .init(0.0, 0.0, 0.01, 0.0),
            .init(0.0, 0.0, 0.0, 1.0)
        ) * .init(
            .init(-1.0, 0.0, 0.0, 0.0),
            .init(0.0, 1.0, 0.0, 0.0),
            .init(0.0, 0.0, -1.0, 0.0),
            .init(0.0, 0.0, 0.0, 1.0)
        )
        bootNode.simdWorldPosition = .init(0.0, 0.0, 0.0)
//        * .init(
//            .init(0.0, 0.0, 0.0, -0.5),
//            .init(0.0, 0.0, 0.0, 0.0),
//            .init(0.0, 0.0, 0.0, -0.5),
//            .init(0.0, 0.0, 0.0, 1.0)
//        )
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateVisualization(newTransform: float4x4, currentPointCloud: ARPointCloud) {
        // Update the transform
        self.simdTransform = newTransform
        
        // Update the point cloud visualization
        updatePointCloud(currentPointCloud)
        
        if boundingBox == nil {
            let scale = CGFloat(referenceObject.scale.x)
            let boundingBox = DetectedBoundingBox(points: referenceObject.rawFeaturePoints.points, scale: scale)
            boundingBox.isHidden = customModel != nil
            addChildNode(boundingBox)
            self.boundingBox = boundingBox
        }
        
        // This visualization should only displayed for displayDuration seconds on every update.
        self.detectedObjectVisualizationTimer?.invalidate()
        self.isHidden = false
        self.detectedObjectVisualizationTimer = Timer.scheduledTimer(withTimeInterval: displayDuration, repeats: false) { _ in
            self.isHidden = true
        }
    }
    
    func updatePointCloud(_ currentPointCloud: ARPointCloud) {
        pointCloudVisualization.updateVisualization(for: currentPointCloud)
    }
}
