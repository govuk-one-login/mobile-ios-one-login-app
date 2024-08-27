import Authentication
import Foundation
import Networking
import SecureStore

protocol SessionManager {
    // func refreshStorage(accessControlLevel: SecureStorageConfiguration.AccessControlLevel?)

    var expiryDate: Date? { get }
    
    var sessionExists: Bool { get }
    var isSessionValid: Bool { get }
    var isReturningUser: Bool { get }

    var user: User? { get }

    var isPersistentSessionIDMissing: Bool { get }

    var tokenProvider: TokenHolder { get }

    /// Starts a new session from a remote login
    func startSession(using session: LoginSession) async throws

    /// Resumes an existing session by restoring tokens from on-device storage
    func resumeSession() throws

    func endCurrentSession()
    func clearAllSessionData()
}
