import Foundation
import UserNotifications

enum PermissionState: Equatable, Sendable {
    case notDetermined
    case granted
    case denied
    case provisional
    case ephemeral
}

extension PermissionState {
    init(_ status: UNAuthorizationStatus) {
        switch status {
        case .notDetermined: self = .notDetermined
        case .authorized: self = .granted
        case .provisional: self = .provisional
        case .ephemeral: self = .ephemeral
        @unknown default: self = .denied
        }
    }
}
