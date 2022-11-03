
import UIKit

final class TapGestureRecognizer: UITapGestureRecognizer {
    
    private let action: () -> Void

    init(action: @escaping () -> Void) {
        self.action = action
        super.init(target: nil, action: nil)
        self.addTarget(self, action: #selector(self.executeAction))
    }

    @objc
    private func executeAction() {
        self.action()
    }
}
