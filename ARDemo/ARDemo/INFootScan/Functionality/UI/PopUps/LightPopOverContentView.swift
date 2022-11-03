import UIKit

final class LightPopOverContentView: UIView {
    
    // MARK: - Variables
    
    private let imageSize = CGSize(width: 120, height: 120)
    private let imageOffset = 34
    private let secondaryLabelOffset = 34
    
    // MARK: - GUI variables
    
    private lazy var mainLabel = BaseLabel(config: .init(
        title: "popUp-light-title",
        font: CustomFonts.merriweatherBold(size: 24)))
    
    private lazy var secondaryLabel = BaseLabel(config: .init(
        title: "popUp-light-subTitle",
        font: CustomFonts.lato(size: 18),
        textColor: UIColor(named: "textSecondaryColor")))
    
    private lazy var image = UIImageView(image: .init(named: "lightPopOverImage"))
    
    // MARK: - Initialization
    
    init() {
        super.init(frame: .zero)
        self.addViews()
        self.backgroundColor = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Adding views
    
    private func addViews() {
        self.addSubviews([self.mainLabel,
                          self.image,
                          self.secondaryLabel])
    }
    
    // MARK: - Constraints
    
    override func updateConstraints() {
        super.updateConstraints()
        mainLabel.snp.updateConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        image.snp.updateConstraints { make in
            make.top.equalTo(mainLabel.snp.bottom).offset(imageOffset)
            make.centerX.equalToSuperview()
            make.size.equalTo(imageSize)
        }
        secondaryLabel.snp.updateConstraints { make in
            make.top.equalTo(image.snp.bottom).offset(secondaryLabelOffset)
            make.leading.trailing.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
        }
    }
}
