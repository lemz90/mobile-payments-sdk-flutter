import SquareMobilePaymentsSDK

public enum TrackingConsent: String {
    case pending     = "PENDING"
    case granted     = "GRANTED"
    case denied      = "DENIED"
    case notRequired = "NOT_REQUIRED"
    case unknown     = "UNKNOWN"

    init(from state: TrackingConsentState) {
        switch state {
        case .pending:     self = .pending
        case .granted:     self = .granted
        case .denied:      self = .denied
        case .notRequired: self = .notRequired
        @unknown default:  self = .unknown
        }
    }

    init(rawValue: UInt) {
        if let sdkState = TrackingConsentState(rawValue: rawValue) {
            self.init(from: sdkState)
        } else {
            self = .unknown
        }
    }
}

