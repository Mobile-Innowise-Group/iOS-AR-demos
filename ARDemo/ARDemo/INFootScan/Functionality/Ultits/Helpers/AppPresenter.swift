import UIKit
import StandardCyborgFusion

/// this class is responsible for configure full app flow and allow to 'construct app by feature toogles'
final class AppPresenter {
    
    // MARK: - variables
    private var currentFlow: FlowType?
    private var serverError: Error?
    private var allowedFlows: [FlowType] = []
    private var sceneModels: [FootSideType: SceneModel] = [:]
    
    // MARK: - gui

    private lazy var interactor: ScanningInteractor = .init()
    private weak var scanningController: ScanningViewController?
    private weak var loaderViewController: LoaderViewController?
    private weak var measureController: FootMeasureViewController?
    // MARK: - initialization
    
    func startFlow() {
        self.setAllowedFlowsByToogles()
        self.setNextFlowAndOpen()
    }
    
    private func setNextFlowAndOpen() {
        if !self.allowedFlows.isEmpty {
            self.currentFlow = self.allowedFlows.removeFirst()
        }

        self.openFlowByCurrent()
    }
    
    private func openFlowByCurrent() {
        switch self.currentFlow {
        case nil:
            self.popToRootAndClear()
        case .scan:
            self.startScanFlow()
        case .preview:
            self.showPreviewVc(foot: .right)
        case .measuring:
            self.startFootMeasuring()
        case .status:
            self.startStatusFlow()
        }
    }
    
    // MARK: - flow settup
    
    private func setAllowedFlowsByToogles() {
        self.allowedFlows = [.scan, .preview, .measuring, .status]
    }
    
    // MARK: - scanning flow
    
    private func startScanFlow(for foot: FootSideType = .right,
                               isSingleFootScanning: Bool = false,
                               screenshotImage: UIImage? = nil) {
        let scanningVC = ScanningViewController(selectedFoot: foot,
                                                withScanPreparing: !isSingleFootScanning,
                                                screenshotImage: screenshotImage,
                                                longWaitingAction: { [weak self] in self?.presentFirstStepManualScanningOverlay() },
                                                completionHandler: { [weak self] model in
            self?.handleScanCompletion(foot: foot, model: model, isSingleFootScanning: isSingleFootScanning)
        })
        scanningVC.modalPresentationStyle = .fullScreen
        self.scanningController = scanningVC

        foot == .right && !isSingleFootScanning
        ? RouteHelper.sh.pushVC(scanningVC)
        : RouteHelper.sh.setVC(scanningVC)

    }
    
    private func handleScanCompletion(foot: FootSideType, model: SceneModel, isSingleFootScanning: Bool) {
        self.sceneModels[foot] = model
        if isSingleFootScanning {
            self.showPreviewVc(foot: foot)
        } else if foot == .right {
            self.startScanFlow(for: .left, screenshotImage: model.screenshotImage)
        } else {
            self.saveFilesIfPreviewNotAllowed { [weak self] in
                self?.setNextFlowAndOpen()
            }
        }
    }
    
    // MARK: - preview flow
    
    private func showPreviewVc(foot: FootSideType, withPush: Bool = false) {
        guard let model = self.sceneModels[foot] else { return }
        
        let vc = ScenePreviewViewController(scScene: SCScene(pointCloud: model.pointCloud, mesh: model.mesh),
                                            selectedFoot: foot)
        vc.leftButtonAction = { [weak self] in
            self?.startScanFlow(for: foot, isSingleFootScanning: true)
        }
        
        vc.righButtonAction = { [weak self] in
            guard let self = self else { return }
            self.saveScene(model, foot: foot)
        }
        
        withPush ? RouteHelper.sh.pushVC(vc) : RouteHelper.sh.setVC(vc)
    }
    
    func saveScene(_ sceneModel: SceneModel, foot: FootSideType) {
        self.interactor.saveSceneAndImage(sceneModel, foot: foot) { [weak self] in
            guard let self = self else { return }
            if foot == .left {
                self.setNextFlowAndOpen()
            } else {
                self.showPreviewVc(foot: .left, withPush: true)
            }
        }
    }
    
    // MARK: - measuring flow

    private func startFootMeasuring(measureType: FootMeasureViewController.MeasureType = .length,
                                    footSideType: FootSideType = .right) {
        let vc = FootMeasureViewController(measureType: measureType,
                                           footSideType: footSideType,
                                           continueButtonAction: { [weak self] _ in
            self?.setNextFlowAndOpen()
        },
                                           inAppRulerAction: { [weak self] in self?.openARRuler() })
        self.measureController = vc
        RouteHelper.sh.pushVC(vc)
    }
    
    private func openARRuler() {
        let vc = ARMeasureViewController { [weak self] value in
            guard let value = value else { return }
            self?.measureController?.setMeasureValue(value)
        }
        RouteHelper.sh.pushVC(vc)
    }
    
    // MARK: - status flow
    
    private func startStatusFlow() {
        let vc = StatusViewController(completionHandler: { [weak self] in
            self?.popToRootAndClear()
        },
                                      shareButtonAction: { [weak self] in self?.interactor.exportFiles() })
        RouteHelper.sh.pushVC(vc, animated: true)
    }
    
    private func saveFilesIfPreviewNotAllowed(completionHandler: @escaping () -> Void) {
        guard !self.allowedFlows.contains(.preview), let leftModel = self.sceneModels[.left], let rightModel = self.sceneModels[.right] else {
            completionHandler()
            return
        }
        
        self.interactor.saveSceneAndImage(rightModel, foot: .right) { [weak self, weak leftModel] in
            guard let self = self, let model = leftModel else { return }
            self.interactor.saveSceneAndImage(model, foot: .left) { completionHandler() }
        }
    }
    
    // MARK: - loader view controller
    
    private func showLoader() {
        let vc = LoaderViewController()
        self.loaderViewController = vc
        RouteHelper.sh.presentOnWindowVC(vc)
    }
    
    private func hideLoader() {
        RouteHelper.sh.dismissVC()
    }
    
    // MARK: - manual scanning overlays
    
    private func presentFirstStepManualScanningOverlay() {
        let view = ManualScanningFirstStepView()
        let vc = OverlayController(view: view)
        vc.closeAction = { [weak self] in  self?.presentSecondStepManualScanningOverlay() }
        view.continueAction = { [weak vc] in vc?.closeVC() }
        RouteHelper.sh.presentVC(vc)
    }
    
    private func presentSecondStepManualScanningOverlay() {
        let view = ManualScanningSecondStepView()
        let vc = OverlayController(view: view)
        vc.closeAction = { [weak self] in self?.scanningController?.showManualScanningView() }
        view.continueAction = { [weak vc] in vc?.closeVC() }
        RouteHelper.sh.presentVC(vc)
    }
    
    // MARK: - clearing
    
    private func popToRootAndClear() {
        self.clearPresenter()
        RouteHelper.sh.popToRoot()
    }
    
    private func clearPresenter() {
        self.currentFlow = nil
        self.serverError = nil
        self.allowedFlows = []
        self.clearFiles()
        self.loaderViewController = nil
        self.scanningController = nil
        self.measureController = nil
    }
    
    private func clearFiles() {
        self.interactor.clear()
        self.sceneModels = [:]
    }
}
