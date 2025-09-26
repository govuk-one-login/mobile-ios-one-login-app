import Foundation

enum AppLocalAuthState: Equatable {
    /// An error occurred in local authentication
    case failed(_ error: Error)
    /// User session expired
    case expired
    /// No user session
    case notLoggedIn
    /// User explicitly logged out of the app
    case loggedOut
    /// User session exists, has not expired and retrieved into memory
    case loggedIn

    static func == (lhs: AppLocalAuthState, rhs: AppLocalAuthState) -> Bool {
        switch (lhs, rhs) {
        case (.failed, .failed),
            (.expired, .expired),
            (.notLoggedIn, .notLoggedIn),
            (.loggedOut, .loggedOut),
            (.loggedIn, .loggedIn):
            return true
        default:
            return false
        }
    }
}
