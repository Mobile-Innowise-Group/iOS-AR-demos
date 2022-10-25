import UIKit

enum FootSideType: String {
    case left = "scan-leftFoot-title"
    case right = "scan-rightFoot-title"
    
    func getBaseImage() -> String {
        switch self {
        case .left: return "leftNotSelected"
        case .right: return "rightNotSelected"
        }
    }
    
    func getPreviewContinueButtonTitle() -> String {
        switch self {
        case .left: return "scan-leftFoot-continueButton-title"
        case .right: return "scan-rightFoot-continueButton-title"
        }
    }
    
    func getDescriptionTitle() -> String {
        switch self {
        case .left: return "scan-placeLeftFoot-title"
        case .right: return "scan-placeRightFoot-title"
        }
    }
    
    func getVoiceHowerDescriptionTitle() -> String {
        switch self {
        case .left: return "scan-voiceHower-placeLeftFoot-title"
        case .right: return "scan-voiceHowerplaceRightFoot-title"
        }
    }
    
    func getFilePath() -> String {
        switch self {
        case .left: return AppConstants.leftFootFile
        case .right: return AppConstants.rightFootFile
        }
    }
    
    func getImagePath() -> String {
        switch self {
        case .left: return AppConstants.leftFootImageFile
        case .right: return AppConstants.rightFootImageFile
        }
    }
    
    func getPreviewTitle(text: String?, boldPart: String?, size: CGFloat) -> NSMutableAttributedString {
        if let text = text {
            let boldText = boldPart ?? "\(self.rawValue.localized)!"
            let textComponents = text.components(separatedBy: boldText)
            if let startText = textComponents.first, let endText = textComponents.last, startText != endText {
                return self.getAttributedPreviewTitleText(startText: startText, boldText: boldText, endText: endText, size: size)
            } else {
                return NSMutableAttributedString().normal(text)
            }
        } else {
            return self.getDefaultPreviewTitle(forSize: size)
        }
    }
    
    private func getDefaultPreviewTitle(forSize: CGFloat) -> NSMutableAttributedString {
        self.getAttributedPreviewTitleText(startText: "scan-review-title".localized,
                                           boldText: "\(self.rawValue.localized)!",
                                           endText: "scan-reviewSecond-title".localized, size: forSize)
    }
    
    private func getAttributedPreviewTitleText(startText: String,
                                               boldText: String,
                                               endText: String,
                                               size: CGFloat) -> NSMutableAttributedString {
        var attributedText = NSMutableAttributedString().normal(startText)
        attributedText = attributedText.normal(boldText, font: .merriweatherBold(size: size))
        attributedText = attributedText.normal(endText)
        
        return attributedText
    }
}
