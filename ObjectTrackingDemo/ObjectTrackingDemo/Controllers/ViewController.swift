/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Main view controller for the object scanning UI.
*/

import UIKit
import SceneKit
import ARKit

public final class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate, UIDocumentPickerDelegate {

    static let appStateChangedNotification = Notification.Name("ApplicationStateChanged")
    static let appStateUserInfoKey = "AppState"

    static var instance: ViewController?

    lazy var sceneView: ARSCNView = {
        let view = ARSCNView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var backButton: UIBarButtonItem!
    var mergeScanButton: UIBarButtonItem!

    lazy var startOverButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setTitle("Restart", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(restartButtonTapped(_:)), for: .touchUpInside)
        return button
    }()

    lazy var instructionView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentView.addSubview(instructionLabel)
        NSLayoutConstraint.activate([
            instructionLabel.leadingAnchor.constraint(equalTo: view.contentView.leadingAnchor, constant: 8.0),
            instructionLabel.trailingAnchor.constraint(equalTo: view.contentView.trailingAnchor, constant: -8.0),
            instructionLabel.topAnchor.constraint(equalTo: view.contentView.topAnchor, constant: 8.0),
            instructionLabel.bottomAnchor.constraint(equalTo: view.contentView.bottomAnchor, constant: -8.0)
        ])
        return view
    }()

    lazy var instructionLabel: MessageLabel = {
        let label = MessageLabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.widthAnchor.constraint(lessThanOrEqualToConstant: 300.0).isActive = true
        label.heightAnchor.constraint(greaterThanOrEqualToConstant: 22.0).isActive = true
        return label
    }()

    lazy var sessionInfoView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentView.addSubview(sessionInfoLabel)
        NSLayoutConstraint.activate([
            sessionInfoLabel.leadingAnchor.constraint(equalTo: view.contentView.leadingAnchor, constant: 8.0),
            sessionInfoLabel.trailingAnchor.constraint(equalTo: view.contentView.trailingAnchor, constant: -14.0),
            sessionInfoLabel.topAnchor.constraint(equalTo: view.contentView.topAnchor, constant: 8.0),
            sessionInfoLabel.bottomAnchor.constraint(equalTo: view.contentView.bottomAnchor, constant: -8.0)
        ])
        return view
    }()

    lazy var sessionInfoLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.widthAnchor.constraint(lessThanOrEqualToConstant: 300.0).isActive = true
        label.heightAnchor.constraint(greaterThanOrEqualToConstant: 22.0).isActive = true
        return label
    }()

    lazy var loadModelButton: RoundedButton = {
        let button = RoundedButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 110.0).isActive = true
        button.heightAnchor.constraint(equalToConstant: 45.0).isActive = true
        button.setTitle("Load Model", for: .normal)
        button.addTarget(self, action: #selector(loadModelButtonTapped(_:)), for: .touchUpInside)
        return button
    }()

    lazy var flashlightButton: FlashlightButton = {
        let button = FlashlightButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 110.0).isActive = true
        button.heightAnchor.constraint(equalToConstant: 45.0).isActive = true
        button.setTitle("Light Off", for: .normal)
        button.addTarget(self, action: #selector(toggleFlashlightButtonTapped(_:)), for: .touchUpInside)
        return button
    }()

    lazy var nextButton: RoundedButton = {
        let button = RoundedButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 100.0).isActive = true
        button.heightAnchor.constraint(equalToConstant: 45.0).isActive = true
        button.setTitle("Next", for: .normal)
        button.addTarget(self, action: #selector(nextButtonTapped(_:)), for: .touchUpInside)
        return button
    }()

    lazy var toggleInstructionsButton: RoundedButton = {
        let button = RoundedButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 45.0).isActive = true
        button.heightAnchor.constraint(equalToConstant: 45.0).isActive = true
        button.addTarget(self, action: #selector(toggleInstructionsButtonTapped(_:)), for: .touchUpInside)
        button.setTitle("?", for: .normal)
        return button
    }()

    internal var internalState: State = .startARSession

    internal var scan: Scan?

    var referenceObjectToMerge: ARReferenceObject?
    var referenceObjectToTest: ARReferenceObject?

    internal var testRun: TestRun?

    internal var messageExpirationTimer: Timer?
    internal var startTimeOfLastMessage: TimeInterval?
    internal var expirationTimeOfLastMessage: TimeInterval?

    internal var screenCenter = CGPoint()

    var modelURL: URL? {
        didSet {
            if let url = modelURL {
                displayMessage("3D model \"\(url.lastPathComponent)\" received.", expirationTime: 3.0)
            }
            if let scannedObject = self.scan?.scannedObject {
                scannedObject.set3DModel(modelURL)
            }
            if let dectectedObject = self.testRun?.detectedObject {
                dectectedObject.set3DModel(modelURL)
            }
        }
    }

    var instructionsVisible: Bool = true {
        didSet {
            instructionView.isHidden = !instructionsVisible
            toggleInstructionsButton.toggledOn = instructionsVisible
        }
    }

    // MARK: - UIViewController Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        guard ARObjectScanningConfiguration.isSupported, ARWorldTrackingConfiguration.isSupported else {
            fatalError("""
                ARKit is not available on this device. For apps that require ARKit
                for core functionality, use the `arkit` key in the key in the
                `UIRequiredDeviceCapabilities` section of the Info.plist to prevent
                the app from installing. (If the app can't be installed, this error
                can't be triggered in a production scenario.)
                In apps where AR is an additive feature, use `isSupported` to
                determine whether to show UI for launching AR experiences.
            """) // For details, see https://developer.apple.com/documentation/arkit
        }
        
        sceneView.delegate = self
        sceneView.session.delegate = self
        
        // Prevent the screen from being dimmed after a while.
        UIApplication.shared.isIdleTimerDisabled = true
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(
            self,
            selector: #selector(scanningStateChanged),
            name: Scan.stateChangedNotification,
            object: nil
        )
        notificationCenter.addObserver(
            self,
            selector: #selector(ghostBoundingBoxWasCreated),
            name: ScannedObject.ghostBoundingBoxCreatedNotification,
            object: nil
        )
        notificationCenter.addObserver(
            self,
            selector: #selector(ghostBoundingBoxWasRemoved),
            name: ScannedObject.ghostBoundingBoxRemovedNotification,
            object: nil
        )
        notificationCenter.addObserver(
            self,
            selector: #selector(boundingBoxWasCreated),
            name: ScannedObject.boundingBoxCreatedNotification,
            object: nil
        )
        notificationCenter.addObserver(
            self,
            selector: #selector(scanPercentageChanged),
            name: BoundingBox.scanPercentageChangedNotification,
            object: nil
        )
        notificationCenter.addObserver(
            self,
            selector: #selector(boundingBoxPositionOrExtentChanged(_:)),
            name: BoundingBox.extentChangedNotification,
            object: nil
        )
        notificationCenter.addObserver(
            self,
            selector: #selector(boundingBoxPositionOrExtentChanged(_:)),
            name: BoundingBox.positionChangedNotification,
            object: nil
        )
        notificationCenter.addObserver(
            self,
            selector: #selector(objectOriginPositionChanged(_:)),
            name: ObjectOrigin.positionChangedNotification,
            object: nil
        )
        notificationCenter.addObserver(
            self,
            selector: #selector(displayWarningIfInLowPowerMode),
            name: Notification.Name.NSProcessInfoPowerStateDidChange,
            object: nil
        )
        
        setupNavigationBar()
        
        displayWarningIfInLowPowerMode()

        view.addSubview(sceneView)
        sceneView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            sceneView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sceneView.topAnchor.constraint(equalTo: view.topAnchor),
            sceneView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sceneView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        sceneView.addSubview(toggleInstructionsButton)
        sceneView.addSubview(nextButton)
        sceneView.addSubview(flashlightButton)
        sceneView.addSubview(loadModelButton)
        sceneView.addSubview(sessionInfoView)
        sceneView.addSubview(instructionView)
        sceneView.addSubview(startOverButton)

        NSLayoutConstraint.activate([
            toggleInstructionsButton.centerYAnchor.constraint(equalTo: nextButton.centerYAnchor),
            toggleInstructionsButton.trailingAnchor.constraint(equalTo: sceneView.trailingAnchor, constant: -20),

            nextButton.centerXAnchor.constraint(equalTo: sessionInfoLabel.centerXAnchor),
            nextButton.centerYAnchor.constraint(equalTo: flashlightButton.centerYAnchor),

            flashlightButton.leadingAnchor.constraint(equalTo: sceneView.leadingAnchor, constant: 20.0),
            flashlightButton.bottomAnchor.constraint(equalTo: sceneView.bottomAnchor, constant: -40.0),

            loadModelButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadModelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40.0),

            sessionInfoView.centerXAnchor.constraint(equalTo: sceneView.centerXAnchor),
            sessionInfoView.topAnchor.constraint(equalTo: sceneView.safeAreaLayoutGuide.topAnchor, constant: 40.0),

            instructionView.centerXAnchor.constraint(equalTo: sceneView.centerXAnchor),
            instructionView.leadingAnchor.constraint(equalTo: sceneView.leadingAnchor, constant: 120.0),
            instructionView.trailingAnchor.constraint(equalTo: sceneView.trailingAnchor, constant: -120.0),
            instructionView.bottomAnchor.constraint(equalTo: sceneView.bottomAnchor, constant: -135.0),
            instructionView.heightAnchor.constraint(greaterThanOrEqualToConstant: 25.0),

            startOverButton.trailingAnchor.constraint(equalTo: sceneView.trailingAnchor, constant: -24.0),
            startOverButton.centerYAnchor.constraint(equalTo: sceneView.centerYAnchor)
        ])
        

        let tapReco = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
        sceneView.addGestureRecognizer(tapReco)

        let singlePanReco = UIPanGestureRecognizer(target: self, action: #selector(didOneFingerPan(_:)))
        sceneView.addGestureRecognizer(singlePanReco)

        let twoPanReco = ThresholdPanGestureRecognizer(target: self, action: #selector(didTwoFingerPan(_:)))
        twoPanReco.minimumNumberOfTouches = 2
        twoPanReco.maximumNumberOfTouches = 2
        sceneView.addGestureRecognizer(twoPanReco)

        let rotReco = ThresholdRotationGestureRecognizer(target: self, action: #selector(didRotate(_:)))
        rotReco.rotation = 0.0
        sceneView.addGestureRecognizer(rotReco)

        let pinchReco = ThresholdPinchGestureRecognizer(target: self, action: #selector(didPinch(_:)))
        pinchReco.scale = 1.0
        sceneView.addGestureRecognizer(pinchReco)

        let longPressReco = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(_:)))
        longPressReco.minimumPressDuration = 0.4
        sceneView.addGestureRecognizer(longPressReco)
                                                  

        // Make sure the application launches in .startARSession state.
        // Entering this state will run() the ARSession.
        state = .startARSession
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ViewController.instance = self
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        if let scene = buildConverse() {
//            let pyramid = subScene.rootNode.childNodeWithName("pyramid", recursively: true)!

//            scene.rootNode.addChildNode(pyramid)
//            let converse = scene.rootNode.childNode(withName: "default", recursively: true)!
//            sceneView.scene.rootNode.addChildNode(converse)
//            sceneView.scene = scene
//            scene.rootNode.childNodes
//        }
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Store the screen center location after the view's bounds did change,
        // so it can be retrieved later from outside the main thread.
        screenCenter = sceneView.center
    }

    // MARK: - UI Event Handling

    // MARK: - startOverButton
    @objc
    func restartButtonTapped(_ sender: Any) {
        if let scan = scan, scan.boundingBoxExists {
            let title = "Start over?"
            let message = "Discard the current scan and start over?"
            self.showAlert(title: title, message: message, buttonTitle: "Yes", showCancel: true) { _ in
                self.state = .startARSession
            }
        } else if testRun != nil {
            let title = "Start over?"
            let message = "Discard this scan and start over?"
            self.showAlert(title: title, message: message, buttonTitle: "Yes", showCancel: true) { _ in
                self.state = .startARSession
            }
        } else {
            self.state = .startARSession
        }
    }
    
    func backFromBackground() {
        if state == .scanning {
            let title = "Warning: Scan may be broken"
            let message = "The scan was interrupted. It is recommended to restart the scan."
            let buttonTitle = "Restart Scan"
            self.showAlert(title: title, message: message, buttonTitle: buttonTitle, showCancel: true) { _ in
                self.state = .notReady
            }
        }
    }

    @objc
    func previousButtonTapped(_ sender: Any) {
        switchToPreviousState()
    }

    // MARK: - nextButton
    @objc
    func nextButtonTapped(_ sender: Any) {
        guard !nextButton.isHidden && nextButton.isEnabled else { return }
        switchToNextState()
    }

    @objc
    func addScanButtonTapped(_ sender: Any) {
        guard state == .testing else { return }

        let title = "Merge another scan?"
        let message = """
            Merging multiple scan results improves detection.
            You can start a new scan now to merge into this one, or load an already scanned *.arobject file.
            """
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Merge New Scan…", style: .default) { _ in
            // Save the previously scanned object as the object to be merged into the next scan.
            self.referenceObjectToMerge = self.testRun?.referenceObject
            self.state = .startARSession
        })
        alertController.addAction(UIAlertAction(title: "Merge ARObject File…", style: .default) { _ in
            // Show a document picker to choose an existing scan
            self.showFilePickerForLoadingScan()
        })
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func showFilePickerForLoadingScan() {
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["com.apple.arobject"], in: .import)
        documentPicker.delegate = self
        
        documentPicker.modalPresentationStyle = .overCurrentContext
        documentPicker.popoverPresentationController?.barButtonItem = mergeScanButton
        
        DispatchQueue.main.async {
            self.present(documentPicker, animated: true, completion: nil)
        }
    }

    // MARK: - loadModelButton
    @objc
    func loadModelButtonTapped(_ sender: Any) {
        guard !loadModelButton.isHidden && loadModelButton.isEnabled else { return }
        
        let documentPicker = UIDocumentPickerViewController(
            documentTypes: ["com.pixar.universal-scene-description-mobile"],
            in: .import
        )
        documentPicker.delegate = self
        
        documentPicker.modalPresentationStyle = .overCurrentContext
        documentPicker.popoverPresentationController?.sourceView = self.loadModelButton
        documentPicker.popoverPresentationController?.sourceRect = self.loadModelButton.bounds
        
        DispatchQueue.main.async {
            self.present(documentPicker, animated: true, completion: nil)
        }
    }
    
//    @IBAction func leftButtonTouchAreaTapped(_ sender: Any) {
//        // A tap in the extended hit area on the lower left should cause a tap
//        //  on the button that is currently visible at that location.
//        if !loadModelButton.isHidden {
//            loadModelButtonTapped(self)
//        } else if !flashlightButton.isHidden {
//            toggleFlashlightButtonTapped(self)
//        }
//    }

    // MARK: flashlightButton
    @objc
    func toggleFlashlightButtonTapped(_ sender: Any) {
        guard !flashlightButton.isHidden && flashlightButton.isEnabled else { return }
        flashlightButton.toggledOn = !flashlightButton.toggledOn
    }

    // MARK: - toggleInstructionsButton
    @objc
    func toggleInstructionsButtonTapped(_ sender: Any) {
        guard !toggleInstructionsButton.isHidden && toggleInstructionsButton.isEnabled else { return }
        instructionsVisible.toggle()
    }
    
    func displayInstruction(_ message: Message) {
        instructionLabel.display(message)
        instructionsVisible = true
    }
    
    public func documentPicker(
        _ controller: UIDocumentPickerViewController,
        didPickDocumentsAt urls: [URL]
    ) {
        guard let url = urls.first else { return }
        readFile(url)
    }
    
    func showAlert(title: String, message: String, buttonTitle: String? = "OK", showCancel: Bool = false, buttonHandler: ((UIAlertAction) -> Void)? = nil) {
        print(title + "\n" + message)
        
        var actions = [UIAlertAction]()
        if let buttonTitle = buttonTitle {
            actions.append(UIAlertAction(title: buttonTitle, style: .default, handler: buttonHandler))
        }
        if showCancel {
            actions.append(UIAlertAction(title: "Cancel", style: .cancel))
        }
        self.showAlert(title: title, message: message, actions: actions)
    }
    
    func showAlert(title: String, message: String, actions: [UIAlertAction]) {
        let showAlertBlock = {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            actions.forEach { alertController.addAction($0) }
            DispatchQueue.main.async {
                self.present(alertController, animated: true, completion: nil)
            }
        }
        
        if presentedViewController != nil {
            dismiss(animated: true) {
                showAlertBlock()
            }
        } else {
            showAlertBlock()
        }
    }
    
    func testObjectDetection() {
        // In case an object for testing has been received, use it right away...
        if let object = referenceObjectToTest {
            testObjectDetection(of: object)
            referenceObjectToTest = nil
            return
        }
        
        // ...otherwise attempt to create a reference object from the current scan.
        guard let scan = scan, scan.boundingBoxExists else {
            print("Error: Bounding box not yet created.")
            return
        }
        
        scan.createReferenceObject { scannedObject in
            if let object = scannedObject {
                self.testObjectDetection(of: object)
            } else {
                let title = "Scan failed"
                let message = "Saving the scan failed."
                let buttonTitle = "Restart Scan"
                self.showAlert(title: title, message: message, buttonTitle: buttonTitle, showCancel: false) { _ in
                    self.state = .startARSession
                }
            }
        }
    }
    
    func testObjectDetection(of object: ARReferenceObject) {
        self.testRun?.setReferenceObject(object, screenshot: scan?.screenshot)
        
        // Delete the scan to make sure that users cannot go back from
        // testing to scanning, because:
        // 1. Testing and scanning require running the ARSession with different configurations,
        //    thus the scanned environment is lost when starting a test.
        // 2. We encourage users to move the scanned object during testing, which invalidates
        //    the feature point cloud which was captured during scanning.
        self.scan = nil
        self.displayInstruction(Message("""
                    Test detection of the object from different angles. Consider moving the object to different environments and test there.
                    """))
    }
    
    func createAndShareReferenceObject() {
        guard let testRun = self.testRun, let object = testRun.referenceObject, let name = object.name else {
            print("Error: Missing scanned object.")
            return
        }
        
        let documentURL = FileManager.default.temporaryDirectory.appendingPathComponent(name + ".arobject")
        
        DispatchQueue.global().async {
            do {
                try object.export(to: documentURL, previewImage: testRun.previewImage)
            } catch {
                fatalError("Failed to save the file to \(documentURL)")
            }
            
            // Initiate a share sheet for the scanned object
            let airdropShareSheet = ShareScanViewController(sourceView: self.nextButton, sharedObject: documentURL)
            DispatchQueue.main.async {
                self.present(airdropShareSheet, animated: true, completion: nil)
            }
        }
    }
    
    var limitedTrackingTimer: Timer?
    
    func startLimitedTrackingTimer() {
        guard limitedTrackingTimer == nil else { return }
        
        limitedTrackingTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
            self.cancelLimitedTrackingTimer()
            guard let scan = self.scan else { return }
            if scan.state == .defineBoundingBox || scan.state == .scanning || scan.state == .adjustingOrigin {
                let title = "Limited Tracking"
                let message = "Low tracking quality - it is unlikely that a good reference object can be generated from this scan."
                let buttonTitle = "Restart Scan"
                
                self.showAlert(title: title, message: message, buttonTitle: buttonTitle, showCancel: true) { _ in
                    self.state = .startARSession
                }
            }
        }
    }
    
    func cancelLimitedTrackingTimer() {
        limitedTrackingTimer?.invalidate()
        limitedTrackingTimer = nil
    }
    
    var maxScanTimeTimer: Timer?
    
    func startMaxScanTimeTimer() {
        guard maxScanTimeTimer == nil else { return }
        
        let timeout: TimeInterval = 60.0 * 5
        
        maxScanTimeTimer = Timer.scheduledTimer(withTimeInterval: timeout, repeats: false) { _ in
            self.cancelMaxScanTimeTimer()
            guard self.state == .scanning else { return }
            let title = "Scan is taking too long"
            let message = "Scanning consumes a lot of resources. This scan has been running for \(Int(timeout)) s. Consider closing the app and letting the device rest for a few minutes."
            let buttonTitle = "OK"
            self.showAlert(title: title, message: message, buttonTitle: buttonTitle, showCancel: true)
        }
    }
    
    func cancelMaxScanTimeTimer() {
        maxScanTimeTimer?.invalidate()
        maxScanTimeTimer = nil
    }
    
    // MARK: - ARSessionDelegate
    
    public func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        
        updateSessionInfoLabel(for: camera.trackingState)
        
        switch camera.trackingState {
        case .notAvailable:
            state = .notReady
        case .limited(let reason):
            switch state {
            case .startARSession:
                state = .notReady
            case .notReady, .testing:
                break
            case .scanning:
                if let scan = scan {
                    switch scan.state {
                    case .ready:
                        state = .notReady
                    case .defineBoundingBox, .scanning, .adjustingOrigin:
                        if reason == .relocalizing {
                            // If ARKit is relocalizing we should abort the current scan
                            // as this can cause unpredictable distortions of the map.
                            print("Warning: ARKit is relocalizing")
                            
                            let title = "Warning: Scan may be broken"
                            let message = "A gap in tracking has occurred. It is recommended to restart the scan."
                            let buttonTitle = "Restart Scan"
                            self.showAlert(title: title, message: message, buttonTitle: buttonTitle, showCancel: true) { _ in
                                self.state = .notReady
                            }
                            
                        } else {
                            // Suggest the user to restart tracking after a while.
                            startLimitedTrackingTimer()
                        }
                    }
                }
            }
        case .normal:
            if limitedTrackingTimer != nil {
                cancelLimitedTrackingTimer()
            }
            
            switch state {
            case .startARSession, .notReady:
                state = .scanning
            case .scanning, .testing:
                break
            }
        }
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard let frame = sceneView.session.currentFrame else { return }
        scan?.updateOnEveryFrame(frame)
        testRun?.updateOnEveryFrame()
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let objectAnchor = anchor as? ARObjectAnchor {
            if let testRun = self.testRun, objectAnchor.referenceObject == testRun.referenceObject {
                testRun.successfulDetection(objectAnchor)
                let messageText = """
                    Object successfully detected from this angle.

                    """ + testRun.statistics
                displayMessage(messageText, expirationTime: testRun.resultDisplayDuration)
                
                
//                let bundle = Bundle.main
//                let path = bundle.path(forResource: "converse_obj", ofType: "obj")
//                let url = URL(fileURLWithPath: path!)
//                let asset = MDLAsset(url: url)
//                let footNode = SCNNode(mdlObject: asset.object(at: 0))
//                node.addChildNode(footNode)
            }
        } else if state == .scanning, let planeAnchor = anchor as? ARPlaneAnchor {
            scan?.scannedObject.tryToAlignWithPlanes([planeAnchor])
            
            // After a plane was found, disable plane detection for performance reasons.
            sceneView.stopPlaneDetection()
        }
    }
    
    func readFile(_ url: URL) {
        if url.pathExtension == "arobject" {
            loadReferenceObjectToMerge(from: url)
        } else if url.pathExtension == "usdz" {
            modelURL = url
        }
    }
    
    fileprivate func mergeIntoCurrentScan(referenceObject: ARReferenceObject, from url: URL) {
        if self.state == .testing {
            
            // Show activity indicator during the merge.
            ViewController.instance?.showAlert(title: "", message: "Merging other scan into this scan...", buttonTitle: nil)
            
            // Try to merge the object which was just scanned with the existing one.
            self.testRun?.referenceObject?.mergeInBackground(with: referenceObject, completion: { (mergedObject, error) in
                let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
                
                if let mergedObject = mergedObject {
                    self.testRun?.setReferenceObject(mergedObject, screenshot: nil)
                    self.showAlert(title: "Merge successful", message: "The other scan has been merged into this scan.",
                                   buttonTitle: "OK", showCancel: false)
                    
                } else {
                    print("Error: Failed to merge scans. \(error?.localizedDescription ?? "")")
                    alertController.title = "Merge failed"
                    let message = """
                            Merging the other scan into the current scan failed. Please make sure
                            that there is sufficient overlap between both scans and that the
                            lighting environment hasn't changed drastically.
                            Which scan do you want to use to proceed testing?
                            """
                    let currentScan = UIAlertAction(title: "Use Current Scan", style: .default)
                    let otherScan = UIAlertAction(title: "Use Other Scan", style: .default) { _ in
                        self.testRun?.setReferenceObject(referenceObject, screenshot: nil)
                    }
                    self.showAlert(title: "Merge failed", message: message, actions: [currentScan, otherScan])
                }
            })
            
        } else {
            // Upon completion of a scan, we will try merging
            // the scan with this ARReferenceObject.
            self.referenceObjectToMerge = referenceObject
            self.displayMessage("Scan \"\(url.lastPathComponent)\" received. " +
                "It will be merged with this scan before proceeding to Test mode.", expirationTime: 3.0)
        }
    }
    
    func loadReferenceObjectToMerge(from url: URL) {
        do {
            let receivedReferenceObject = try ARReferenceObject(archiveURL: url)
            
            // Ask the user if the received object should be merged into the current scan,
            // or if the received scan should be tested (and the current one discarded).
            let title = "Scan \"\(url.lastPathComponent)\" received"
            let message = """
                Do you want to merge the received scan into the current scan,
                or test only the received scan, discarding the current scan?
                """
            let merge = UIAlertAction(title: "Merge Into This Scan", style: .default) { _ in
                self.mergeIntoCurrentScan(referenceObject: receivedReferenceObject, from: url)
            }
            let test = UIAlertAction(title: "Test Received Scan", style: .default) { _ in
                self.referenceObjectToTest = receivedReferenceObject
                self.state = .testing
            }
            self.showAlert(title: title, message: message, actions: [merge, test])
            
        } catch {
            self.showAlert(title: "File invalid", message: "Loading the scanned object file failed.",
                           buttonTitle: "OK", showCancel: false)
        }
    }
    
    @objc
    func scanPercentageChanged(_ notification: Notification) {
        guard let percentage = notification.userInfo?[
            BoundingBox.scanPercentageUserInfoKey
        ] as? Int else { return }
        
        // Switch to the next state if the scan is complete.
        if percentage >= 100 {
            switchToNextState()
            return
        }
        DispatchQueue.main.async {
            self.setNavigationBarTitle("Scan (\(percentage)%)")
        }
    }
    
    @objc
    func boundingBoxPositionOrExtentChanged(_ notification: Notification) {
        guard let box = notification.object as? BoundingBox,
            let cameraPos = sceneView.pointOfView?.simdWorldPosition else { return }
        
        let xString = String(format: "width: %.2f", box.extent.x)
        let yString = String(format: "height: %.2f", box.extent.y)
        let zString = String(format: "length: %.2f", box.extent.z)
        let distanceFromCamera = String(format: "%.2f m", distance(box.simdWorldPosition, cameraPos))
        displayMessage("Current bounding box: \(distanceFromCamera) away\n\(xString) \(yString) \(zString)", expirationTime: 1.5)
    }
    
    @objc
    func objectOriginPositionChanged(_ notification: Notification) {
        guard let node = notification.object as? ObjectOrigin else { return }
        
        // Display origin position w.r.t. bounding box
        let xString = String(format: "x: %.2f", node.position.x)
        let yString = String(format: "y: %.2f", node.position.y)
        let zString = String(format: "z: %.2f", node.position.z)
        displayMessage("Current local origin position in meters:\n\(xString) \(yString) \(zString)", expirationTime: 1.5)
    }
    
    @objc
    func displayWarningIfInLowPowerMode() {
        if ProcessInfo.processInfo.isLowPowerModeEnabled {
            let title = "Low Power Mode is enabled"
            let message = "Performance may be impacted. For best scanning results, disable Low Power Mode in Settings > Battery, and restart the scan."
            let buttonTitle = "OK"
            self.showAlert(title: title, message: message, buttonTitle: buttonTitle, showCancel: false)
        }
    }
    
    public override var shouldAutorotate: Bool {
        false
        // Lock UI rotation after starting a scan
//        if let scan = scan, scan.state != .ready {
//            return false
//        }
//        return true
    }
}
