import UIKit

struct TrailFadingLoaderConfig {
    let fromColor: UIColor
    let toColor: UIColor
    let lineWidth: CGFloat = 3.0
    let animationDuration: Double = 1.0
}

//TODO: - refactor with custom loader
final class TrailFadingLoader: UIView {
    
    // MARK: - Variables
    private let colorOne: UIColor
    private let colorTwo: UIColor
    private let lineWidth: CGFloat
    private let duration: Double
    
    // MARK: - GUI variables
    private lazy var shapeLayer: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.type = .conic
        gradient.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradient.endPoint = CGPoint(x: 0.5, y: 0)
        gradient.colors = [
            self.colorOne.cgColor,
            self.colorTwo.cgColor
        ]
        gradient.locations = [0, 1]
        return gradient
    }()
    
    private lazy var backgroundLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.red.cgColor
        layer.lineWidth = self.lineWidth
        layer.fillColor = UIColor.clear.cgColor
        layer.lineCap = .round
        return layer
    }()
    
    // MARK: - Initiazlization
    init(config: TrailFadingLoaderConfig) {
        self.colorTwo = config.fromColor
        self.colorOne = config.toColor
        self.lineWidth = config.lineWidth
        self.duration = config.animationDuration
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
        
        let backgroundPath = UIBezierPath(ovalIn: shapeLayer.frame.inset(by: UIEdgeInsets(top: self.lineWidth,
                                                                                          left: self.lineWidth,
                                                                                          bottom: self.lineWidth,
                                                                                          right: self.lineWidth)))
        
        self.backgroundLayer.path = backgroundPath.cgPath
        self.shapeLayer.frame = path.bounds
        self.shapeLayer.mask = backgroundLayer
    }
    
    // MARK: - Actions
    func startAnimating() {
        let startAnimation = RotationAnimation(duration: self.duration)
        
        let strokeAnimationGroup = CAAnimationGroup()
        strokeAnimationGroup.duration = 1
        strokeAnimationGroup.repeatDuration = .infinity
        strokeAnimationGroup.animations = [startAnimation]
        shapeLayer.add(strokeAnimationGroup, forKey: nil)
        self.layer.addSublayer(shapeLayer)
    }
    
    func stopAnimation() {
        self.shapeLayer.removeAllAnimations()
        self.shapeLayer.removeFromSuperlayer()
    }
    
    private func setupUI() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .clear
    }
}
