import Foundation
import CoreVideo
import Accelerate
import CoreMedia
import AVFoundation

extension CVPixelBuffer {
    func getDepthDistanceToPoint(point: CGPoint) -> Float {
        CVPixelBufferLockBaseAddress(self, .readOnly)
        guard let rawPointer = CVPixelBufferGetBaseAddress(self) else { return 0 }
        let rowData = rawPointer + Int(point.y) * CVPixelBufferGetBytesPerRow(self)
        var f16Pixel = self.float32to16(&rowData.assumingMemoryBound(to: Float32.self)[Int(point.x)])
        var f32Pixel = Float(0.0)
        
        CVPixelBufferUnlockBaseAddress(self, .readOnly)
        
        withUnsafeMutablePointer(to: &f16Pixel) { f16RawPointer in
            withUnsafeMutablePointer(to: &f32Pixel) { f32RawPointer in
                var src = vImage_Buffer(data: f16RawPointer, height: 1, width: 1, rowBytes: 2)
                var dst = vImage_Buffer(data: f32RawPointer, height: 1, width: 1, rowBytes: 4)
                vImageConvert_Planar16FtoPlanarF(&src, &dst, 0)
            }
        }
        
        return f32Pixel
    }
    
    private func float32to16(_ input: UnsafeMutablePointer<Float>) -> Float16 {
        var output: Float16 = 0
        withUnsafeMutablePointer(to: &output) { output in
            var bufferFloat32 = vImage_Buffer(data: input, height: 1, width: 1, rowBytes: 4)
            var bufferFloat16 = vImage_Buffer(data: output, height: 1, width: 1, rowBytes: 2)
            vImageConvert_PlanarFtoPlanar16F(&bufferFloat32, &bufferFloat16, 0)
        }
    
        return output
    }
}

extension CMSampleBuffer {
    func getBrightness() -> Double? {
        let rawMetadata = CMCopyDictionaryOfAttachments(allocator: nil, target: self, attachmentMode: CMAttachmentMode(kCMAttachmentMode_ShouldPropagate))
        let metadata = CFDictionaryCreateMutableCopy(nil, 0, rawMetadata) as NSMutableDictionary
        let exifData = metadata.value(forKey: "{Exif}") as? NSMutableDictionary
        let brightnessValue: Double? = exifData?[kCGImagePropertyExifBrightnessValue as String] as? Double
        return brightnessValue
    }
}
