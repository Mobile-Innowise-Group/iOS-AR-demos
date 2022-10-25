import Foundation
import Metal
import simd
import StandardCyborgFusion

public class AspectFillTextureCommandEncoder {
    
    private struct Uniforms {
        var transform = simd_float3x3(0)
        var alpha: Float = 0.3
        var memoryPadding = simd_float4(repeating: 0)
    }
    
    private let pipelineState: MTLComputePipelineState?
    private let textureCache: CVMetalTextureCache?
    private var uniforms = Uniforms()
    /// Alpha for camera background content. It needs to be low to see the color of metal background.
    public var alpha: Float = 0.05
    
    init(device: MTLDevice, library: MTLLibrary?) {
        pipelineState = AspectFillTextureCommandEncoder.buildColorPipelineState(withDevice: device, library: library)
        
        var cache: CVMetalTextureCache?
        CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, device, nil, &cache)
        textureCache = cache
    }
    
    
    func encodeCommands(onto commandBuffer: MTLCommandBuffer, colorBuffer: CVPixelBuffer, outputTexture: MTLTexture) {
        guard let colorTexture = metalTexture(fromColorBuffer: colorBuffer) else { return }
        
        uniforms.alpha = alpha
        uniforms.transform = AspectFillTextureCommandEncoder.buildRotateAspectFitTransform(
            sourceWidth: colorTexture.width,
            sourceHeight: colorTexture.height,
            resultWidth: outputTexture.width,
            resultHeight: outputTexture.height)
        
        encodeColorRenderCommands(onto: commandBuffer,
                                  colorTexture: colorTexture,
                                  outputTexture: outputTexture)
    }
    
    // MARK: - Private
    
    private class func buildRotateAspectFitTransform(sourceWidth: Int, sourceHeight: Int, resultWidth: Int, resultHeight: Int) -> simd_float3x3 {
        // Note that the source aspect ratio is inverted. This is because the source
        // data is sideways. It makes things much, much easier to reason about if we
        // think of things in terms of how they show up on the screen
        let sourceAspectRatio = Float(sourceHeight) / Float(sourceWidth)
        let resultAspectRatio = Float(resultWidth) / Float(resultHeight)
        
        // The matrix below is derived in maxima through following steps:
        //   1. scale by the result width/height
        //   2. translate by (-0.5, -0.5)
        //   3. rotate 90 degrees and scale by the aspect ratio
        //   4. translate by (0.5, 0.5)
        //
        // In maxima, that's:
        //  A: matrix([1, 0, -1 / 2], [0, 1, -1 / 2], [0, 0, 1])
        //  C: matrix([0, xScale, 0], [yScale, 0, 0], [0, 0, 1])
        //  B: matrix([1, 0, 1 / 2], [0, 1, 1 / 2], [0, 0, 1])
        //  D: matrix([1 / resultWidth, 0, 0], [0, 1 / resultHeight, 0], [0, 0, 1])
        //
        //  expand(B . C . A . D)
        
        // This enforces either fill (cover if you're into css) by comparing the space we're
        // aiming to fill with the aspect ratio of the input.
        var imageScale: simd_float2
        if sourceAspectRatio > resultAspectRatio {
            // The source data is wider than the display
            imageScale = simd_float2(sourceAspectRatio / resultAspectRatio, 1.0)
        } else {
            // The display is wider than the source data
            imageScale = simd_float2(1.0, resultAspectRatio / sourceAspectRatio)
        }
        
        var transform = simd_float3x3(0)
        transform[1][0] = 1.0 / (imageScale[1] * Float(resultHeight))
        transform[2][0] = 0.5 * (1.0 - 1.0 / imageScale[1])
        transform[0][1] = 1.0 / (imageScale[0] * Float(resultWidth))
        transform[2][1] = 0.5 * (1.0 - 1.0 / imageScale[0])
        
        return transform
    }
    
    private func encodeColorRenderCommands(onto commandBuffer: MTLCommandBuffer, colorTexture: MTLTexture, outputTexture: MTLTexture) {
        let resultWidth = outputTexture.width
        let resultHeight = outputTexture.height
        let threadgroupCounts = MTLSize(width: 8, height: 8, depth: 1)
        let threadgroups = MTLSize(width:  resultWidth  / threadgroupCounts.width  + (resultWidth  % threadgroupCounts.width  == 0 ? 0 : 1),
                                   height: resultHeight / threadgroupCounts.height + (resultHeight % threadgroupCounts.height == 0 ? 0 : 1),
                                   depth: 1)
        
        
        guard let commandEncoder = commandBuffer.makeComputeCommandEncoder(),
              let pipelineState = pipelineState else { return }
        commandEncoder.label = "DrawColorTexture.commandEncoder"
        commandEncoder.setComputePipelineState(pipelineState)
        commandEncoder.setBytes(&uniforms, length: MemoryLayout<Uniforms>.size, index: 0)
        commandEncoder.setTexture(colorTexture, index: 0)
        commandEncoder.setTexture(outputTexture, index: 1)
        commandEncoder.dispatchThreadgroups(threadgroups, threadsPerThreadgroup: threadgroupCounts)
        commandEncoder.endEncoding()
    }
    
    private func metalTexture(fromColorBuffer colorBuffer: CVPixelBuffer) -> MTLTexture? {
        let textureAttributes = [kCVPixelBufferMetalCompatibilityKey: NSNumber(booleanLiteral: true),
                                                kCVMetalTextureUsage: NSNumber(integerLiteral: Int(MTLTextureUsage.shaderRead.rawValue))]
        guard let textureCache = textureCache else { return nil }
        
        var texture: CVMetalTexture?
        CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                  textureCache,
                                                  colorBuffer,
                                                  textureAttributes as CFDictionary,
                                                  MTLPixelFormat.bgra8Unorm,
                                                  CVPixelBufferGetWidthOfPlane(colorBuffer, 0),
                                                  CVPixelBufferGetHeightOfPlane(colorBuffer, 0),
                                                  0,
                                                  &texture)
        
        guard let texture = texture else { return nil }
        
        return CVMetalTextureGetTexture(texture)
    }
    
    private class func buildColorPipelineState(withDevice device: MTLDevice, library: MTLLibrary?) -> MTLComputePipelineState? {
        guard let library = library else { return nil }

        let function = library.makeFunction(name: "DrawColorTexture")
        
        let pipelineDescriptor = MTLComputePipelineDescriptor()
        pipelineDescriptor.computeFunction = function
        pipelineDescriptor.label = "DrawColorTexture.depthColorPipelineState"
        
        guard let function = function else { return nil }
        
        let pipelineState = try? device.makeComputePipelineState(function: function)
        
        return pipelineState
    }
    
}
