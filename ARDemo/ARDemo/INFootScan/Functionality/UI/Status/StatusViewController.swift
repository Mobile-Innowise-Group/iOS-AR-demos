import Foundation
import UIKit

final class StatusViewController: UIViewController {
    
    // MARK: - variables

    private let completionHandler: () -> Void
    private let shareButtonAction: () -> Void
    
    private let buttonInsets = UIEdgeInsets(top: 28, left: 95, bottom: 0, right: 95)
    private let titleDescriptionInsets = UIEdgeInsets(top: 64, left: 38, bottom: 0, right: 38)
    private let buttonHeight = 51
    private let shareButtonOffset = 15
    
    // MARK: - gui variables

    private lazy var iconView: ImageView = .init(imageName: "scanningSuccessImage")
    
    private lazy var titleDescriptionView: TitleDescriptionView = .init(
        title: "statusScreen-successTitle",
        description: "statusScreen-successDescription")
    
    private lazy var doneButton: BaseButton = .init(config: .init(
        title: "statusScreen-successButton-title",
        action: { [weak self] in self?.completionHandler() }))
    
    private lazy var shareButton: BaseButton = {
        let button: BaseButton = .init(config: .init(title: "share-button",
                                                     buttonStyle: .secondary,
                                                     action: { [weak self] in self?.shareButtonAction() }))
        return button
    }()
    
    // MARK: - initialization
    
    init(completionHandler: @escaping () -> Void,
         shareButtonAction: @escaping () -> Void) {
        self.completionHandler = completionHandler
        self.shareButtonAction = shareButtonAction
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.addConstraints()
    }
    
    // MARK: - initialization
    
    private func configView() {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.view.backgroundColor = .white
        self.view.addSubviews([self.iconView,
                               self.titleDescriptionView,
                               self.doneButton,
                               self.shareButton])
    }
    
    // MARK: - constraints
    
    private func addConstraints() {
        self.iconView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        self.titleDescriptionView.snp.makeConstraints { make in
            make.top.equalTo(self.iconView.snp.bottom).offset(self.titleDescriptionInsets.top)
            make.left.right.equalToSuperview().inset(self.titleDescriptionInsets)
        }
        
        self.doneButton.snp.makeConstraints { make in
            make.top.equalTo(self.titleDescriptionView.snp.bottom).offset(self.buttonInsets.top)
            make.trailing.leading.equalToSuperview().inset(self.buttonInsets)
        }

        self.shareButton.snp.makeConstraints { make in
            make.top.equalTo(self.doneButton.snp.bottom).offset(self.shareButtonOffset)
            make.trailing.leading.equalToSuperview().inset(self.buttonInsets)
            make.height.equalTo(self.buttonHeight)
        }
    }
}
