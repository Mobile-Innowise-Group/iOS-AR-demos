
import UIKit

class TappableLabel: BaseLabel {
    
    // MARK: - variables
    
    private var textsWithLink: [String: (() -> Void)?] = [:]
    
    // MARK: - actions
    
    override func initView() {
        super.initView()
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleLabelTap)))
    }
    
    // MARK: - setters
    
    func setLinks(textsWithLink: [String: (() -> Void)?]) {
        self.textsWithLink = textsWithLink
        self.setUpLinks()
    }
    
    private func setUpLinks() {
        guard let text = self.config?.title?.localized else { return }
        let attributedText = NSMutableAttributedString(string: text)
        
        for tappableText in self.textsWithLink.keys {
            let range = (text as NSString).range(of: tappableText)
            attributedText.addAttribute(.foregroundColor, value: UIColor(named: "mainAcceptColor") ?? .blue,
                                        range: range)
            
        }
        self.setAttributedText(attributedText: attributedText)
    }
    
    // MARK: - handle tap
    
    @objc private func handleLabelTap(gesture: UITapGestureRecognizer) {
        guard let text = self.config?.title?.localized else { return }
        for (tappableText, action) in self.textsWithLink {
            let range = (text as NSString).range(of: tappableText)
            if gesture.didTapAttributedTextInLabel(label: self, inRange: range) {
                action?()
            }
        }
    }
}
