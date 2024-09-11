import Foundation

enum AppLocalAuthState: Equatable {
    case userFailed(_ error: Error)
    case userExpired
    case userUnconfirmed
    case userOneTime
    case userConfirmed

    static func == (lhs: AppLocalAuthState, rhs: AppLocalAuthState) -> Bool {
        switch (lhs, rhs) {
        case (.userFailed, .userFailed),
            (.userExpired, .userExpired),
            (.userUnconfirmed, .userUnconfirmed),
            (.userOneTime, .userOneTime),
            (.userConfirmed, .userConfirmed):
            return true
        default:
            return false
        }
    }
}
