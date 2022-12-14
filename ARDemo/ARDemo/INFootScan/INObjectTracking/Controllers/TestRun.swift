/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Manages the process of testing detection after scanning an object.
*/

import Foundation
import ARKit

// This class represents a test run of a scanned object.
class TestRun {
    
    // The ARReferenceObject to be tested in this run.
    var referenceObject: ARReferenceObject?
    
    private(set) var detectedObject: DetectedObject?
    
    var detections = 0
    var lastDetectionDelayInSeconds: Double = 0
    var averageDetectionDelayInSeconds: Double = 0
    
    var resultDisplayDuration: Double {
        // The recommended display duration for detection results
        // is the average time it takes to detect it, plus 200 ms buffer.
        return averageDetectionDelayInSeconds + 0.2
    }
    
    private var lastDetectionStartTime: Date?
    
    private var sceneView: ARSCNView
    
    private(set) var previewImage = UIImage()
    
    init(sceneView: ARSCNView) {
        self.sceneView = sceneView
    }
    
    deinit {
        self.detectedObject?.removeFromParentNode()
        
        if self.sceneView.session.configuration as? ARWorldTrackingConfiguration != nil {
            // Make sure we switch back to an object scanning configuration & no longer
            // try to detect the object.
            let configuration = ARObjectScanningConfiguration()
            configuration.planeDetection = .horizontal
            self.sceneView.session.run(configuration, options: .resetTracking)
        }
    }
    
    var statistics: String {
        let lastDelayMilliseconds = String(format: "%.0f", lastDetectionDelayInSeconds * 1000)
        let averageDelayMilliseconds = String(format: "%.0f", averageDetectionDelayInSeconds * 1000)
        return "Detected after: \(lastDelayMilliseconds) ms. Avg: \(averageDelayMilliseconds) ms"
    }
    
    func buildConverse() -> SCNNode? {
        let scene = SCNScene(named: "Nike_Air_Jordan.scn")
        
        // 2: Add camera node
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        // 3: Place camera
        cameraNode.position = SCNVector3(x: 0, y: 10, z: 35)
        // 4: Set camera on scene
        scene?.rootNode.addChildNode(cameraNode)

        // 5: Adding light to scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 35)
        scene?.rootNode.addChildNode(lightNode)

        // 6: Creating and adding ambien light to scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light?.type = .ambient
        ambientLightNode.light?.color = UIColor.darkGray
        scene?.rootNode.addChildNode(ambientLightNode)

        return scene?.rootNode
        
    }
    func setReferenceObject(_ object: ARReferenceObject, screenshot: UIImage?) {
        referenceObject = object
        if let screenshot = screenshot {
            previewImage = screenshot
        }
        detections = 0
        lastDetectionDelayInSeconds = 0
        averageDetectionDelayInSeconds = 0
        
        self.detectedObject = DetectedObject(referenceObject: object)
        self.sceneView.scene.rootNode.addChildNode(self.detectedObject!)
//        let node = buildConverse()!
//        node.position = .init(object.center.x, object.center.y, object.center.z)
//        node.childNodes.forEach(sceneView.scene.rootNode.addChildNode(_:))
//        self.sceneView.scene.rootNode.addChildNode(node)
        
        self.lastDetectionStartTime = Date()
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.detectionObjects = [object]
        self.sceneView.session.run(configuration)
        ViewController.instance?.displayMessage(
            "SUCCESS ✅"
            , expirationTime: 5.0)
        startNoDetectionTimer()
    }
    
    func successfulDetection(_ objectAnchor: ARObjectAnchor) {
        
        // Compute the time it took to detect this object & the average.
        lastDetectionDelayInSeconds = Date().timeIntervalSince(self.lastDetectionStartTime!)
        detections += 1
        averageDetectionDelayInSeconds = (averageDetectionDelayInSeconds * Double(detections - 1) + lastDetectionDelayInSeconds) / Double(detections)
        
        // Update the detected object's display duration
        self.detectedObject?.displayDuration = resultDisplayDuration
        
        // Immediately remove the anchor from the session again to force a re-detection.
        self.lastDetectionStartTime = Date()
        self.sceneView.session.remove(anchor: objectAnchor)
        
        if let currentPointCloud = self.sceneView.session.currentFrame?.rawFeaturePoints {
            self.detectedObject?.updateVisualization(newTransform: objectAnchor.transform,
                                                     currentPointCloud: currentPointCloud)
        }
        startNoDetectionTimer()
    }
    
    func updateOnEveryFrame() {
        if let detectedObject = self.detectedObject {
            if let currentPointCloud = self.sceneView.session.currentFrame?.rawFeaturePoints {
                detectedObject.updatePointCloud(currentPointCloud)
            }
        }
    }
    
    var noDetectionTimer: Timer?
    
    func startNoDetectionTimer() {
        cancelNoDetectionTimer()
        noDetectionTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { _ in
            self.cancelNoDetectionTimer()
            ViewController.instance?.displayMessage("""
                Unable to detect the object.
                Please point the device at the scanned object, rescan or add another scan
                of this object in the current environment.
                """, expirationTime: 5.0)
        }
    }
    
    func cancelNoDetectionTimer() {
        noDetectionTimer?.invalidate()
        noDetectionTimer = nil
    }
}
