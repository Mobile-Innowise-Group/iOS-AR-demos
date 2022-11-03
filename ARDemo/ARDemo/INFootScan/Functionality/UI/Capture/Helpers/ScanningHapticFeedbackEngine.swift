import AudioToolbox
import Foundation
import UIKit

/** Manages haptic feedback in response to changes in the scanning state */
final class ScanningHapticFeedbackEngine {
    
    
    // MARK: - variables
    
    static let shared = ScanningHapticFeedbackEngine()
    
    private let hapticImpactMedium = UIImpactFeedbackGenerator(style: UIImpactFeedbackGenerator.FeedbackStyle.medium)
    private let hapticSelection = UISelectionFeedbackGenerator()
    private let hapticNotification = UINotificationFeedbackGenerator()
    
    private let scanningTimerInterval = 1.0 / 8.0
    private var scanningTimer: Timer?
    
    // MARK: - init
    
    init() {
        [self.hapticImpactMedium, self.hapticSelection, self.hapticNotification].forEach { $0.prepare() }
    }
    
    // MARK: - actions
    
    func countdownCountedDown() {
        self.hapticImpactMedium.impactOccurred()
    }
    
    func scanningBegan() {
        self.startScanningTimer()
    }
    
    func scanningFinished() {
        self.stopScanningTimer()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(100)) {
            self.hapticNotification.notificationOccurred(UINotificationFeedbackGenerator.FeedbackType.success)
        }
    }
    
    func scanningCanceled() {
        self.stopScanningTimer()
        self.hapticNotification.notificationOccurred(UINotificationFeedbackGenerator.FeedbackType.error)
    }
    
    func stopScanningTimer() {
        self.scanningTimer?.invalidate()
        self.scanningTimer = nil
    }
    
    private func startScanningTimer() {
        self.scanningTimer = Timer.scheduledTimer(withTimeInterval: scanningTimerInterval,
                                                  repeats: true,
                                                  block: { [weak self] timer in
            self?.hapticSelection.selectionChanged()
        })
    }
}
