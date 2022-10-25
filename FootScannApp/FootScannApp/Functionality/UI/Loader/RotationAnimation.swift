import UIKit

final class RotationAnimation: CABasicAnimation {
    
    // MARK: - Initialization
    init(duration: Double) {
        super.init()
        self.keyPath = "transform.rotation"
        self.toValue = NSNumber(value: Double.pi * 2)
        self.isCumulative = true
        self.duration = duration
        self.repeatCount = Float.greatestFiniteMagnitude
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
