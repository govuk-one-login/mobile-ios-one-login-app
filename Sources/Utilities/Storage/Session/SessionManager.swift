import Authentication
import Foundation
import LocalAuthenticationWrapper

enum UserState {
    case authenticated
    case notAuthenticated
}

enum SessionState {
    case nonePresent
    case enrolling
    case oneTime
    case saved
    case expired
}

protocol SessionManager: AnyObject, UserProvider {
    var sessionState: SessionState { get }
    
    var expiryDate: Date? { get }
    var isReturningUser: Bool { get }
    var isEnrolling: Bool { get set }

    var tokenProvider: TokenHolder { get }

    var localAuthentication: LocalAuthManaging { get }
    
    var persistentID: String? { get }

    /// Starts a new session from a remote login
    func startSession(
        _ session: LoginSession,
        using configuration: @Sendable (String?) async throws -> LoginSessionConfiguration
    ) async throws

    /// Resumes an existing session by restoring tokens from on-device storage
    func resumeSession() throws

    /// Saves session details by storing tokens in on-device storage
    func saveSession() throws

    /// Ends the current session - removing and deleting session related data such as access and ID token
    func endCurrentSession()

    /// Completely removes all user session data (including the persistent session and Wallet data) from the device
    func clearAllSessionData(restartLoginFlow: Bool) async throws
}

extension SessionManager {
    // provide default value
    func clearAllSessionData(restartLoginFlow: Bool = true) async throws {
        try await clearAllSessionData(restartLoginFlow: restartLoginFlow)
    }
}
