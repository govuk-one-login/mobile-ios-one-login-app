import Authentication
import Foundation
import Networking
import SecureStore

enum UserState {
    case authenticated
    case notAuthenticated
}

protocol SessionManager: UserProvider {
    var expiryDate: Date? { get }
    
    var sessionExists: Bool { get }
    var isSessionValid: Bool { get }
    var isReturningUser: Bool { get }
    var isOneTimeUser: Bool { get }

    var tokenProvider: TokenHolder { get }

    var localAuthentication: LocalAuthenticationManager & LocalAuthenticationContextStringCheck { get }

    /// Starts a new session from a remote login
    func startSession(
        _ session: LoginSession,
        using configuration: @Sendable (String?) async throws -> LoginSessionConfiguration
    ) async throws

    /// Resumes an existing session by restoring tokens from on-device storage
    func resumeSession() throws

    /// Saves session details by storing tokens in on-device storage
    func saveSession() async throws

    /// Ends the current session - removing and deleting session related data such as access and ID token
    func endCurrentSession()

    /// Completely removes all user session data (including the persistent session and Wallet data) from the device
    func clearAllSessionData() async throws
}
