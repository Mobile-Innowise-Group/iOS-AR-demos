import UIKit

final class StrokeAnimation: CABasicAnimation {
    
    enum StrokeType: String {
        case start = "strokeStart"
        case end = "strokeEnd"
    }
    
    // MARK: - Initialization
    init(type: StrokeType,
         beginTime: Double = 0.0,
         fromValue: CGFloat,
         toValue: CGFloat,
         duration: Double) {
        super.init()
        self.keyPath = type == .start ? StrokeType.start.rawValue : StrokeType.end.rawValue
        self.beginTime = beginTime
        self.fromValue = fromValue
        self.toValue = toValue
        self.duration = duration
        self.timingFunction = .init(name: .easeInEaseOut)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
