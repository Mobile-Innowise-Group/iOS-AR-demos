
import UIKit

class ImageView: UIImageView {
    
    // MARK: - variables
    
    var action: (() -> Void)?
    
    var isRounded: Bool = false {
        didSet {
            guard self.isRounded else { return }
            self.clipsToBounds = true
            self.layer.cornerRadius = self.frame.height / 2
        }
    }
    
    // MARK: - initialization
    
    init(imageName: String? = nil, systemName: String? = nil, withRenderingMode: Bool = false) {
        super.init(frame: CGRect.zero)
        if let imageName = imageName {
            self.set(imageName: imageName, withRenderingMode: withRenderingMode)
        } else if let systemName = systemName {
            self.set(systemImageName: systemName, withRenderingMode: withRenderingMode)
        }
        
        self.initView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initView() {
        self.contentMode = .scaleAspectFit
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(TapGestureRecognizer(action: { [weak self] in self?.action?() }))
    }
    
    // MARK: - actions
    
    func makeRoundedWithBorder(borderWidth: CGFloat, borderColor: UIColor) {
        self.image = self.image?.roundedImageWithBorder(width: borderWidth, color: borderColor)
    }
    
    func set(imageName: String, withRenderingMode: Bool = false) {
        self.image = UIImage(named: imageName)?
            .withRenderingMode(withRenderingMode ? .alwaysTemplate : .alwaysOriginal)
    }
    
    func set(systemImageName: String, withRenderingMode: Bool = false) {
        self.image = UIImage(systemName: systemImageName)?
            .withRenderingMode(withRenderingMode ? .alwaysTemplate : .alwaysOriginal)
    }
}
