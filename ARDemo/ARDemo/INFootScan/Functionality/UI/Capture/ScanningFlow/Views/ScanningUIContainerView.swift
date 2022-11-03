import UIKit

final class ScanningUIContainerView: UIView {
    
    // MARK: - ui variables
    
    var showManualViewAction: (() -> Void)?
    var shutterButtonAction: (() -> Void)?
    var configureSessionAction: (() -> Void)?
    
    private var screenshotImage: UIImage?
    private(set) var screenshotPreviewImage: UIImage?
    private var isPoorlightAlertPresented: Bool = false
    private let selectedFoot: FootSideType
    private let withScanPreparing: Bool
    
    private let previewShowingDelay: Double = 1
    private let manualScanStartDelay: Double = 1.2
    
    private var isAllowToShowAnotherAlert = true
    private var protectedFromDismiss = false
    private var isPoorLightAlertPresented = false
    private let timeBetweenAlerts: TimeInterval = 5
    private let poorLightAlertDuration: TimeInterval = 2
    private let loadingIndicatorSize = CGSize(width: 60, height: 60)
    
    var isFootDetected: Bool {
        set { self.updateUIByDetectedFoot(isFootDetected: newValue) }
        get { self.scanningView.isFootDetected }
    }
    
    private var isPrescanViewHidden: Bool = false {
        didSet { self.setScanViewIfNeeded() }
    }

    
    // MARK: - gui variables
    
    private lazy var speakHelper: SpeakHelper = .init()
    
    private lazy var loadingIndicator: TrailFadingLoader = {
        let indicator = TrailFadingLoader(config: .init(fromColor: UIColor.white, toColor: UIColor.clear))
        indicator.isHidden = true
        return indicator
    }()
    
    private(set) lazy var scanningView: ScanningView = {
        let view: ScanningView = .init(selectedFoot: self.selectedFoot,
                                       screenshotImage: self.screenshotImage)
        view.isHidden = true
        return view
    }()
    
    private lazy var preScanView: ScanPreparingView = .init(selectedFoot: self.selectedFoot,
                                                            withScanPreparing: self.withScanPreparing,
                                                            preparingAction: { [weak self] in self?.scanPreparingAction() },
                                                            startScanningAction: { [weak self] in
        self?.isPrescanViewHidden = true
    })
    
    private lazy var manualScanningView: ManualScanPreparingView = {
        let view: ManualScanPreparingView = .init(viewShouldAppearAction: { [weak self] in
            self?.dismissPoorLightAlertIfNeeded()
            self?.showManualViewAction?()
        }, startScanningAction: { [weak self] in
            self?.startManualScanningIfNeeded()
        })
        
        view.isHidden = true
        return view
    }()
    
    private lazy var poorLightAlert: PopOverView = {
        let lightPopOverContentView = LightPopOverContentView()
        let popOverView = PopOverView(contentView: lightPopOverContentView)
        popOverView.dismissInTime = true
        popOverView.duration = self.poorLightAlertDuration
        return popOverView
    }()
    
    // MARK: - initialization
    
    init(selectedFoot: FootSideType,
         withScanPreparing: Bool = false,
         screenshotImage: UIImage? = nil) {
        self.selectedFoot = selectedFoot
        self.withScanPreparing = withScanPreparing
        self.screenshotImage = screenshotImage
        super.init(frame: .zero)
        self.initView()
        self.backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initView() {
        self.addSubviews([self.preScanView,
                          self.scanningView,
                          self.manualScanningView,
                          self.loadingIndicator])
        self.preScanView.cameraView.start()
    }
    
    // MARK: - constraints
    
    override func updateConstraints() {
        super.updateConstraints()
        
        self.loadingIndicator.snp.updateConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(self.loadingIndicatorSize)
        }
        
        self.preScanView.snp.updateConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.scanningView.snp.updateConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.manualScanningView.snp.updateConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // MARK: - actions
    
    func startPreviewActionIfNeeded() {
        self.preScanView.startScanPreviewActionIfNeeded()
    }
    
    func setScanViewIfNeeded() {
        guard self.isPrescanViewHidden else { return }
        self.speakHelper.voiceTheText("scan-detectFoot-voice-title".accessibility)
        
        self.preScanView.animateHidingOrShowing { [weak self] in
            self?.scanningView.animateHidingOrShowing() { [weak self] in
                guard self?.isFootDetected == false else { return }
                self?.startShutterButtonTimerIfNeeded()
            }
        }
        
        self.preScanView.cameraView.stop()
        self.configureSessionAction?()
    }
    
    func showScreenshotIfNeededAndComplete(completionAction: @escaping () -> Void) {
            completionAction()
    }
    
    func startManualScanningIfNeeded() {
        guard !self.manualScanningView.isHidden else { return }
        self.manualScanningView.cameraView.stop()
        self.manualScanningView.animateHidingOrShowing { [weak self] in
            self?.isFootDetected = true
            self?.scanningView.animateHidingOrShowing {
                self?.scanningViewActionIfNeeded()
                DispatchQueue.main.asyncAfter(deadline: .now() + (self?.manualScanStartDelay ?? 0)) { [weak self] in
                    self?.shutterButtonAction?()
                }
            }
        }
    }
    
    func takeScreenshotOfMetalLayer() {
        self.screenshotPreviewImage = self.scanningView.metalContainerView.takeScreenshot()
    }
    
    func startShutterButtonTimerIfNeeded() {
        self.manualScanningView.startShutterButtonTimer()
    }
    
    func showManualScanningView() {
        self.scanningView.animateHidingOrShowing { [weak self] in
            self?.manualScanningView.cameraView.start { [weak self] in
                self?.manualScanningView.animateHidingOrShowing()
                self?.speakHelper.voiceTheText("manualScan-description".accessibility)
            }
        }
    }
    
    func presentPoorLightAlertIfNeeded() {
        guard self.isAllowToShowAnotherAlert && !self.isPoorLightAlertPresented else { return }
        self.isAllowToShowAnotherAlert = false
        self.protectedFromDismiss = true
        
        self.poorLightAlert.present()
        self.isPoorlightAlertPresented = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + self.poorLightAlertDuration) {
            self.protectedFromDismiss = false
            self.isPoorlightAlertPresented = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + self.timeBetweenAlerts) {
                self.isAllowToShowAnotherAlert = true
            }
        }
    }
    
    func dismissPoorLightAlertIfNeeded() {
        guard !self.protectedFromDismiss && self.isPoorLightAlertPresented else { return }
        self.poorLightAlert.dismiss()
        self.isPoorlightAlertPresented = false
    }
    
    private func scanPreparingAction() {
        self.speakHelper.voiceTheText(self.selectedFoot.getVoiceHowerDescriptionTitle().accessibility)
    }
    
    private func updateUIByDetectedFoot(isFootDetected: Bool) {
        self.scanningView.isFootDetected = isFootDetected
        if isFootDetected { self.manualScanningView.stopShutterButtonTimer() }
    }
    
    private func scanningViewActionIfNeeded() {
        guard self.scanningView.isHidden == false else { return }
    }
    
    func showLoader() {
        self.loadingIndicator.startAnimating()
        self.loadingIndicator.isHidden = false
    }
    
    func hideLoaderIfNeeded() {
        guard !loadingIndicator.isHidden else { return }
        self.loadingIndicator.stopAnimation()
        self.loadingIndicator.isHidden = true
    }
}
