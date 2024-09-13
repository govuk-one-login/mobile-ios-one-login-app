import Foundation

enum AppLocalAuthState: Equatable {
    case userFailed(_ error: Error)
    case userExpired
    case userUnconfirmed
    case userConfirmed

    static func == (lhs: AppLocalAuthState, rhs: AppLocalAuthState) -> Bool {
        switch (lhs, rhs) {
        case (.userFailed, .userFailed),
            (.userExpired, .userExpired),
            (.userUnconfirmed, .userUnconfirmed),
            (.userConfirmed, .userConfirmed):
            return true
        default:
            return false
        }
    }
}
