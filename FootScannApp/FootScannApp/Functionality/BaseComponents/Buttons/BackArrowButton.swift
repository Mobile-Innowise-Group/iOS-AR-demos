import UIKit

final class BackArrowButton: ImageView {
    
    // MARK: - variables
    
    var size: CGSize = .init(width: 18, height: 18)
    
    // MARK: - initialization
    
    init() {
        super.init(systemName: "chevron.backward", withRenderingMode: true)
        self.tintColor = UIColor(named: "underlinedTextColor")
        self.isAccessibilityElement = true
        self.accessibilityLabel = "backButton-title".accessibility
        self.accessibilityTraits = .button
        self.action = { RouteHelper.sh.popVC() }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
