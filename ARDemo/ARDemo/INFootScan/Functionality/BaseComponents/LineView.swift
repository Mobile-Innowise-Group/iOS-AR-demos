
import UIKit

final class LineView: UIView {

    //MARK: - properties
    
    var axis: NSLayoutConstraint.Axis = .horizontal {
        didSet { self.invalidateIntrinsicContentSize() }
    }
    
    var heightOfLine: CGFloat = 1.0 / UIScreen.main.scale {
        didSet { self.invalidateIntrinsicContentSize() }
    }

    override var intrinsicContentSize: CGSize {
        switch self.axis {
        case .vertical:
            return CGSize(width: self.heightOfLine, height: UIView.noIntrinsicMetric)
        case .horizontal:
            return CGSize(width: UIView.noIntrinsicMetric, height: self.heightOfLine)
        @unknown default:
            fatalError("intrinsicContentSize has not been implemented")
        }
    }
    
    // MARK: - initialization
    
    init() {
        super.init(frame: CGRect.zero)
        self.backgroundColor = UIColor(named: "placeholderTextColor") ?? .gray
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
