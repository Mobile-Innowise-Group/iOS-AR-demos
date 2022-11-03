
import UIKit

final class ShutterButton: UIButton {
    
    // MARK: - initialization
    
    init() {
        super.init(frame: .zero)
        self.setImage()
        self.accessibilityLabel = "shutter-button".accessibility
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setImage()
    }
    
    // MARK: - actions
    
    func setImage() {
        self.setImage(UIImage(named: "ShutterButton") ?? UIImage(systemName: "circle"), for: UIControl.State.normal)
    }
}
