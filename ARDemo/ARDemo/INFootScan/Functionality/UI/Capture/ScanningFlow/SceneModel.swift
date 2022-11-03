import UIKit
import StandardCyborgFusion

final class SceneModel {
    let meshTexturing: SCMeshTexturing
    let mesh: SCMesh
    let pointCloud: SCPointCloud
    var screenshotImage: UIImage?
    var photoImageData: Data
    
    init(meshTexturing: SCMeshTexturing, mesh: SCMesh, pointCloud: SCPointCloud, screenshotImage: UIImage? = nil, photoImageData: Data) {
        self.meshTexturing = meshTexturing
        self.mesh = mesh
        self.pointCloud = pointCloud
        self.screenshotImage = screenshotImage
        self.photoImageData = photoImageData
    }
}
