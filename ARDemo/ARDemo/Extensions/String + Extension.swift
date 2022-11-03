import UIKit

extension String {
    
    var digits: String {
        return components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
    }
    
    var localized: String {
        return LocalizationAndAccessibilityHelper.shared.localized(key: self)
    }
    
    var accessibility: String {
        return LocalizationAndAccessibilityHelper.shared.accessibilityText(key: self)
    }
    
    static func ~= (lhs: String, rhs: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: rhs) else { return false }
        let range = NSRange(location: 0, length: lhs.utf16.count)
        return regex.firstMatch(in: lhs, options: [], range: range) != nil
    }
}

extension NSMutableAttributedString {
    func normal(_ value: String, textColor: UIColor? = nil, font: CustomFonts? = nil) -> NSMutableAttributedString {
        var attributes: [NSAttributedString.Key: Any] = [:]
        
        if let textColor = textColor { attributes[.foregroundColor] = textColor }
        
        if let font = font { attributes[.font] = font.getFont() }
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
}
