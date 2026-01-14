import Foundation

enum AppSessionState: Equatable {
    /// An error occurred in local authentication
    case failed(_ error: Error)
    /// User session expired
    case expired
    /// No user session
    case notLoggedIn
    /// System purposefully logged user out of the app
    case systemLogOut
    /// User explicitly logged out of the app
    case userLogOut
    /// User cancelled local auth for session
    case localAuthCancelled
    /// User session exists, has not expired and retrieved into memory
    case loggedIn

    static func == (lhs: AppSessionState, rhs: AppSessionState) -> Bool {
        switch (lhs, rhs) {
        case (.failed, .failed),
            (.expired, .expired),
            (.notLoggedIn, .notLoggedIn),
            (.systemLogOut, .systemLogOut),
            (.userLogOut, .userLogOut),
            (.localAuthCancelled, .localAuthCancelled),
            (.loggedIn, .loggedIn):
            return true
        default:
            return false
        }
    }
}
