import UIKit

enum CustomFonts {
    case lato(size: CGFloat)
    case latoBold(size: CGFloat)
    case latoBlack(size: CGFloat)
    case merriweather(size: CGFloat)
    case merriweatherBold(size: CGFloat)
    
    func getFont() -> UIFont {
        switch self {
        case .lato(size: let size):
            return UIFont(name: "Lato-Regular", size: size) ?? UIFont.systemFont(ofSize: size)
        case .latoBold(size: let size):
            return UIFont(name: "Lato-Bold", size: size) ?? UIFont.systemFont(ofSize: size, weight: .bold)
        case .latoBlack(size: let size):
            return UIFont(name: "Lato-Black", size: size) ?? UIFont.systemFont(ofSize: size, weight: .semibold)
        case .merriweather(size: let size):
            return UIFont(name: "Merriweather-Regular", size: size) ?? UIFont.systemFont(ofSize: size)
        case .merriweatherBold(size: let size):
            return UIFont(name: "Merriweather-Bold", size: size) ?? UIFont.systemFont(ofSize: size, weight: .bold)
        }
    }
}
