

import AVFoundation
import Foundation
import Metal
import StandardCyborgFusion

class DefaultScanningViewRenderer: ScanningViewRenderer {
    
    private let commandQueue: MTLCommandQueue
    private let drawTextureCommandEncoder: AspectFillTextureCommandEncoder
    private let pointCloudRenderer: PointCloudCommandEncoder
    
    var flipsInputHorizontally: Bool = false
    
    required init(device: MTLDevice, commandQueue: MTLCommandQueue) {
        self.commandQueue = commandQueue
        
        let library = device.makeDefaultLibrary()
        drawTextureCommandEncoder = AspectFillTextureCommandEncoder(device: device, library: library)
        pointCloudRenderer = PointCloudCommandEncoder(device: device, library: library)
    }
    
    func draw(colorBuffer: CVPixelBuffer?,
              pointCloud: SCPointCloud?,
              depthCameraCalibrationData: AVCameraCalibrationData,
              viewMatrix: matrix_float4x4,
              into metalLayer: CAMetalLayer) {
        autoreleasepool {
            let commandBuffer = commandQueue.makeCommandBuffer()
            guard let commandBuffer = commandBuffer else { return }
            commandBuffer.label = "ScanningViewRenderer.commandBuffer"
            
            guard let drawable = metalLayer.nextDrawable() else { return }
            let outputTexture = drawable.texture
            
            if let colorBuffer = colorBuffer {
                drawTextureCommandEncoder.encodeCommands(onto: commandBuffer,
                                                          colorBuffer: colorBuffer,
                                                          outputTexture: outputTexture)
            }
            
            if let pointCloud = pointCloud {
                pointCloudRenderer.encodeCommands(onto: commandBuffer,
                                                   pointCloud: pointCloud,
                                                   depthCameraCalibrationData: depthCameraCalibrationData,
                                                   viewMatrix: viewMatrix,
                                                   pointSize: 16,
                                                   flipsInputHorizontally: flipsInputHorizontally,
                                                   outputTexture: outputTexture)
            }
            
            commandBuffer.present(drawable)
            commandBuffer.commit()
            commandBuffer.waitUntilScheduled()
        }
    }
}
