
import Vision

extension VNRecognizedObjectObservation {
    var label: String? {
        return self.labels.first?.identifier
    }
}
