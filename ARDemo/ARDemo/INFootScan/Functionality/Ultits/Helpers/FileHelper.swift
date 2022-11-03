
import UIKit
import SceneKit
import StandardCyborgFusion

final class FileHelper {
    
    private let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first

    func saveSceneAndImage(scene: SCScene?,
                   imageData: Data,
                   footType: FootSideType,
                           completion: @escaping (_ filePath: URL, _ imagePath: URL) -> Void) {
        guard let scene = scene, let documentsURL = documentsURL else { return }
        let swiftScene = SCNScene()
        swiftScene.rootNode.addChildNode(scene.rootNode)
        ///used for sending model in real size 
        swiftScene.rootNode.scale = SCNVector3(1000, 1000, 1000)
        
        let filePath = documentsURL.appendingPathComponent(footType.getFilePath())
        let imagePath = documentsURL.appendingPathComponent(footType.getImagePath())
        
        DispatchQueue.global().async {
            self.removeItemIfNeeded(at: filePath)
            self.removeItemIfNeeded(at: imagePath)
            
            swiftScene.write(to: filePath, delegate: nil)
            try? imageData.write(to: imagePath)
            
            DispatchQueue.main.async { completion(filePath, imagePath) }
        }
    }
    
    func export(paths: [String]) {
        guard let topController = RouteHelper.sh.navController?.topViewController else { return }
        let files = paths.compactMap { [weak self] path in self?.documentsURL?.appendingPathComponent(path) }
        let vc = UIActivityViewController(activityItems: files, applicationActivities: nil)
        vc.isModalInPresentation = true
        vc.popoverPresentationController?.sourceView = topController.view
        topController.present(vc, animated: true, completion: nil)
    }
    
    func getDataFile(path: URL) -> FeetFile? {
        guard let fileData = FileManager.default.contents(atPath: path.path) else { return nil }
        return FeetFile(fileData: fileData, fileName: path.lastPathComponent)
    }
    
    private func removeItemIfNeeded(at path: URL) {
        guard FileManager.default.fileExists(atPath: path.path) else { return }
        try? FileManager.default.removeItem(at: path)
    }
}
