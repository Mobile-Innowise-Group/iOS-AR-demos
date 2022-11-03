import Foundation
import AVFoundation

/// This class allow us to speak some texts outloud
final class SpeakHelper: NSObject {
    
    // MARK: - varaibles
    
    private let synth = AVSpeechSynthesizer()
    private var completionHandlers: [(() -> Void)?] = []
    private let audioSession = AVAudioSession.sharedInstance()
    
    // MARK: - initialization
    
    override init() {
        super.init()
        self.synth.delegate = self
        try? self.audioSession.setCategory(.playback)
    }
    
    // MARK: - actions
    
    func voiceTheText(_ text: String, completionHandler: (() -> Void)? = nil) {
        self.completionHandlers.append(completionHandler)
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        self.synth.speak(utterance)
    }
    
    // MARK: - deinit
    
    deinit {
        try? self.audioSession.setCategory(.soloAmbient)
    }
}

extension SpeakHelper: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        guard !self.completionHandlers.isEmpty else { return }
        self.completionHandlers.removeFirst()?()
    }
}
