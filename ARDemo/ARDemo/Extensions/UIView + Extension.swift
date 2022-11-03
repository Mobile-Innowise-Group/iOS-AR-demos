import UIKit

extension UIView {
    func roundCorners(corners: CACornerMask, radius: CGFloat) {
        self.layer.cornerRadius = radius
        self.layer.maskedCorners = corners
    }
    
    func animateHidingOrShowing(duration: TimeInterval = 0.35, completion: (() -> Void)? = nil) {
        UIView.transition(with: self, duration: duration,
                          options: .transitionCrossDissolve,
                          animations: {
            self.isHidden.toggle()
        }) { _ in completion?() }
    }
    
    func takeScreenshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let image = image else { return UIImage() }
        return image
    }
    
    func addSubviews(_ views: [UIView]) {
        views.forEach { self.addSubview($0) }
    }
}
