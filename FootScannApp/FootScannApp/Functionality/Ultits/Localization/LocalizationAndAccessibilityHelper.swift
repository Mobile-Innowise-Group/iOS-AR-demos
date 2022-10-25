import Foundation

/// Easy way of using localization and accessibility texts in one file. If you need add new texts to the app use 'localizationAndAccessibility.json' file
final class LocalizationAndAccessibilityHelper {
    
    // MARK: - variables
    
    private let localizationTexts: [String: LocalizationAndAccessibilityModel]
    static let shared = LocalizationAndAccessibilityHelper()
    
    //MARK: - init
    
    private init() {
        guard let path = Bundle.main.url(forResource: "localizationAndAccessibility",
                                         withExtension: "json"),
              let data = try? Data(contentsOf: path) else {
            self.localizationTexts = [:]
            return
        }
        let model = try? JSONDecoder().decode([String: LocalizationAndAccessibilityModel].self, from: data)
        self.localizationTexts = model ?? [:]
    }
    
    // MARK: - actions
    
    func localized(key: String) -> String {
        return self.localizationTexts[key]?.text ?? key
    }
    
    func accessibilityText(key: String) -> String {
        return self.localizationTexts[key]?.accessibilityText ?? key
    }
}
