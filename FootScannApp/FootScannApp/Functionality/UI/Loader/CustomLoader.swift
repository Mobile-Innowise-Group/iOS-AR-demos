import UIKit

struct CustomLoaderConfig {
    let color: UIColor
    let backgroundCircleColor: UIColor
    let lineWidth: CGFloat = 1.5
}

final class CustomLoader: UIView {
    
    // MARK: - Variables
    private let color: UIColor
    private let backgroundCircleColor: UIColor
    private let lineWidth: CGFloat
    
    // MARK: - GUI variables
    private lazy var shapeLayer: ProgressShapeLayer = .init(strokeColor: self.color,
                                                            lineWidth: self.lineWidth)
    
    private lazy var backgroundLayer: ProgressShapeLayer = .init(
        strokeColor: self.backgroundCircleColor,
        lineWidth: self.lineWidth)
    
    // MARK: - Initiazlization
    init(config: CustomLoaderConfig) {
        self.color = config.color
        self.backgroundCircleColor = config.backgroundCircleColor
        self.lineWidth = config.lineWidth
        super.init(frame: .zero)
        self.setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.width / 2
        let path = UIBezierPath(ovalIn: CGRect(x: 0,
                                               y: 0,
                                               width: self.bounds.width,
                                               height: self.bounds.width))
        self.shapeLayer.path = path.cgPath
        self.backgroundLayer.path = path.cgPath
    }
    
    // MARK: - Actions
    func startAnimating() {
        let startAnimation = StrokeAnimation(
            type: .start,
            beginTime: 0.25,
            fromValue: 0.0,
            toValue: 1.0,
            duration: 0.75
        )
        
        let endAnimation = StrokeAnimation(
            type: .end,
            fromValue: 0.0,
            toValue: 1.0,
            duration: 0.75
        )
        
        let strokeAnimationGroup = CAAnimationGroup()
        strokeAnimationGroup.duration = 1
        strokeAnimationGroup.repeatDuration = .infinity
        strokeAnimationGroup.animations = [startAnimation, endAnimation]
        self.shapeLayer.add(strokeAnimationGroup, forKey: nil)
        self.layer.addSublayer(shapeLayer)
        self.isHidden = false
    }
    
    func stopAnimation() {
        self.shapeLayer.removeAllAnimations()
        self.shapeLayer.removeFromSuperlayer()
        self.isHidden = true
    }
    
    private func setupUI() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .clear
        self.layer.addSublayer(backgroundLayer)
        self.isHidden = true
    }
}
