
import ARKit
import Vision
import UIKit

/// Used for calculating distances between dots, placing them in sceneView and returning lengthes model.
final class DistanceCalculator {

    weak var delegate: ScanningViewControllerDelegate?

    func processPoints(for points: [VNHumanHandPoseObservation.JointName : VNRecognizedPoint]) {
        var lengthModel: LengthModel = .init()

        if let thumbStartPoint = points[.thumbTip],
           let thumbMiddleStartPoint = points[.thumbIP],
           let thumbMiddleEndPoint = points[.thumbMP],
           let thumbEndPoint = points[.thumbCMC] {
            lengthModel.thumbFingerLength = calculateDistanceAndPlaceNodes(fromPoint: thumbStartPoint,
                                                                           middleStartPoint: thumbMiddleStartPoint,
                                                                           middleEndPoint: thumbMiddleEndPoint,
                                                                           toPoint: thumbEndPoint)
        }

        if let indexStartPoint = points[.indexTip],
           let indexMiddleStartPoint = points[.indexDIP],
           let indexMiddleEndPoint = points[.indexPIP],
           let indexEndPoint = points[.indexMCP] {
            lengthModel.indexFingerLength = calculateDistanceAndPlaceNodes(fromPoint: indexStartPoint,
                                                                           middleStartPoint: indexMiddleStartPoint,
                                                                           middleEndPoint: indexMiddleEndPoint,
                                                                           toPoint: indexEndPoint)
        }

        if let middleStartPoint = points[.middleTip],
           let middleMiddleStartPoint = points[.middleDIP],
           let middleMiddleEndPoint = points[.middlePIP],
           let middleEndPoint = points[.middleMCP] {
            lengthModel.middleFingerLength = calculateDistanceAndPlaceNodes(fromPoint: middleStartPoint,
                                                                            middleStartPoint: middleMiddleStartPoint,
                                                                            middleEndPoint: middleMiddleEndPoint,
                                                                            toPoint: middleEndPoint)
        }

        if let ringStartPoint = points[.ringTip],
           let ringMiddleStartPoint = points[.ringDIP],
           let ringMiddleEndPoint = points[.ringPIP],
           let ringEndPoint = points[.ringMCP] {
            lengthModel.ringFingerLength = calculateDistanceAndPlaceNodes(fromPoint: ringStartPoint,
                                                                          middleStartPoint: ringMiddleStartPoint,
                                                                          middleEndPoint: ringMiddleEndPoint,
                                                                          toPoint: ringEndPoint)
        }

        if let smallStartPoint = points[.littleTip],
           let smallMiddleStartPoint = points[.littleDIP],
           let smallMiddleEndPoint = points[.littlePIP],
           let smallEndPoint = points[.littleMCP] {
            lengthModel.smallFingerLength = calculateDistanceAndPlaceNodes(fromPoint: smallStartPoint,
                                                                           middleStartPoint: smallMiddleStartPoint,
                                                                           middleEndPoint: smallMiddleEndPoint,
                                                                           toPoint: smallEndPoint)
        }

        if let indexEndPoint = points[.middleMCP],
           let wristPoint = points[.wrist] {
            lengthModel.palmLength = calculateDistanceAndPlaceNodes(fromPoint: indexEndPoint, toPoint: wristPoint)
        }

        delegate?.setCompletion(model: lengthModel)
    }

    @discardableResult
    private func calculateDistanceAndPlaceNodes(fromPoint: VNRecognizedPoint,
                                                middleStartPoint: VNRecognizedPoint? = nil,
                                                middleEndPoint: VNRecognizedPoint? = nil,
                                                toPoint: VNRecognizedPoint) -> Double {
        guard let startPos = getPositionInScene(from: convertFromCamera(fromPoint)) else { return .zero }
        delegate?.putSphere(at: startPos)

        guard let endPos = getPositionInScene(from: convertFromCamera(toPoint)) else { return .zero }
        delegate?.putSphere(at: endPos)

        if let middleStartPoint = middleStartPoint,
           let middleStartPos = getPositionInScene(from: convertFromCamera(middleStartPoint)),
           let middleEndPoint = middleEndPoint,
           let middleEndPos = getPositionInScene(from: convertFromCamera(middleEndPoint)) {
            delegate?.putSphere(at: middleEndPos)
            delegate?.putSphere(at: middleStartPos)

            delegate?.drawLine(from: startPos,
                               to: middleStartPos,
                               length: (startPos - middleStartPos).length())

            delegate?.drawLine(from: middleStartPos,
                               to: middleEndPos,
                               length: (middleStartPos - middleEndPos).length())

            delegate?.drawLine(from: endPos,
                               to: middleEndPos,
                               length: (endPos - middleEndPos).length())
        } else {
            delegate?.drawLine(from: startPos, to: endPos, length: (startPos - endPos).length())
        }

        let distance = Double((startPos - endPos).length() * 100).rounded(toPlaces: 2)
        return distance
    }

    /// Convert camera point to scene view point.
    private func convertFromCamera(_ point: VNRecognizedPoint) -> CGPoint {
        return CGPoint(x: point.y * AppConstants.screenSize.width,
                       y: point.x * AppConstants.screenSize.width)
    }

    /// Getting real world position.
    private func getPositionInScene(from point: CGPoint) -> SCNVector3? {
        guard let query = delegate?.sceneView.raycastQuery(from: point, allowing: .existingPlaneInfinite, alignment: .any),
              let result = delegate?.sceneView.session.raycast(query),
              let hitResult = result.first?.worldTransform.columns.3 else { return nil }

        let scenePosition = SCNVector3(hitResult.x, hitResult.y, hitResult.z)
        return scenePosition
    }
}
