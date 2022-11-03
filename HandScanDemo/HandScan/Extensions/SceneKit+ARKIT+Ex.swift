import SceneKit
import ARKit

extension ARSession {
    func run() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        configuration.isLightEstimationEnabled = true
        run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
}

extension SCNVector3: Equatable {

    func length() -> Float {
        return sqrtf(x * x + y * y + z * z)
    }

    static func - (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
        return SCNVector3Make(left.x - right.x, left.y - right.y, left.z - right.z)
    }

    static func + (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
        return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
    }

    static func midpoint(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
        return SCNVector3Make((left.x + right.x) / 2, (left.y + right.y) / 2, (left.z + right.z) / 2)
    }

    public static func == (lhs: SCNVector3, rhs: SCNVector3) -> Bool {
        return (lhs.x == rhs.x) && (lhs.y == rhs.y) && (lhs.z == rhs.z)
    }
}

extension SCNNode {
    static func sphereNode(color: UIColor, position: SCNVector3) -> SCNNode {
        let geometry = SCNSphere(radius: 0.003)
        let material = SCNMaterial()
        material.diffuse.contents = color
        geometry.materials = [material]
        let node = SCNNode(geometry: geometry)
        node.position = position
        return node
    }

    static func lineNode(length: CGFloat, color: UIColor) -> SCNNode {
        let geometry = SCNCapsule(capRadius: 0.0015, height: length)
        geometry.materials.first?.diffuse.contents = color
        let line = SCNNode(geometry: geometry)

        let node = SCNNode()
        node.eulerAngles = SCNVector3Make(Float.pi/2, 0, 0)
        node.addChildNode(line)
        return node
    }

    static func textNode(text: String,
                         position: SCNVector3,
                         shouldLookAtNode lookAtNode: SCNNode? = nil,
                         color: UIColor = .yellow) -> SCNNode {
        let geometry = SCNText(string: text, extrusionDepth: 3)
        let material = SCNMaterial()
        material.diffuse.contents = color
        geometry.materials = [material]
        let node = SCNNode(geometry: geometry)

        var pivotCorrection = SCNMatrix4Identity
        if let lookAtNode = lookAtNode {
            let constraint = SCNLookAtConstraint(target: lookAtNode)
            constraint.isGimbalLockEnabled = true
            node.constraints = [constraint]
            pivotCorrection = SCNMatrix4Rotate(pivotCorrection, 2 * .pi / 3, .pi, .pi, .pi)
        }

        let (min, max) = geometry.boundingBox
        pivotCorrection = SCNMatrix4Translate(pivotCorrection, (max.x - min.x) / 2, -.pi, 0)
        node.pivot = pivotCorrection

        node.position = SCNVector3(x: position.x, y: position.y + 0.003, z: position.z)
        node.scale = SCNVector3(x: 0.0007, y: 0.0007, z: 0.0007)
        return node
    }
}


extension ARPlaneAnchor {
    @discardableResult
    func addPlaneNode(on node: SCNNode, geometry: SCNGeometry, contents: Any) -> SCNNode {
        guard let material = geometry.materials.first else { return SCNNode() }

        if let program = contents as? SCNProgram {
            material.program = program
        } else {
            material.diffuse.contents = contents
        }

        let planeNode = SCNNode(geometry: geometry)

        DispatchQueue.main.async(execute: {
            node.addChildNode(planeNode)
        })

        return planeNode
    }

    func addPlaneNode(on node: SCNNode, contents: Any) {
        let geometry = SCNPlane(width: CGFloat(extent.x), height: CGFloat(extent.z))
        let planeNode = addPlaneNode(on: node, geometry: geometry, contents: contents)
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2.0, 1, 0, 0)
    }

    func findPlaneNode(on node: SCNNode) -> SCNNode? {
        for childNode in node.childNodes {
            if childNode.geometry as? SCNPlane != nil { return childNode }
        }
        return nil
    }

    func updatePlaneNode(on node: SCNNode) {
        DispatchQueue.main.async(execute: { [weak self] in
            guard let self = self,
                  let plane = self.findPlaneNode(on: node)?.geometry as? SCNPlane,
                  !self.planeSizeEqualToExtent(plane: plane, extent: self.extent) else { return }

            plane.width = CGFloat(self.extent.x)
            plane.height = CGFloat(self.extent.z)
        })
    }

    fileprivate func planeSizeEqualToExtent(plane: SCNPlane, extent: vector_float3) -> Bool {
        !(plane.width != CGFloat(extent.x) || plane.height != CGFloat(extent.z))
    }
}
