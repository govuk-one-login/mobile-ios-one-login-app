import AppIntegrity
import Authentication
import Foundation
import LocalAuthenticationWrapper

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
    
    var validTokensForRefreshExchange: (idToken: String, refreshToken: String)? { get throws }
    
    var tokenProvider: TokenHolder { get }
    
    var localAuthentication: LocalAuthManaging { get }
    
    var persistentID: String? { get }
    var walletStoreID: String? { get }
    
    /// Starts a new authentication session from a remote login
    func startAuthSession(
        _ session: LoginSession,
        using configuration: @Sendable (String?) async throws -> LoginSessionConfiguration
    ) async throws
    
    /// Saves session details by storing tokens
    func saveAuthSession() throws
    
    /// Saves tokens in on-device storage
    func saveLoginTokens(
        idToken: String?,
        refreshToken: String?,
        accessToken: String?,
        accessTokenExpiry: Date?
    ) throws
    
    /// Resumes an existing session by restoring tokens from on-device storage
    @MainActor
    func resumeSession() async throws

    /// Perform a refresh token exchange for the given `idToken` using the given `refreshToken`.
    ///
    /// Upon a succesful refresh token exchange, the login tokens will be saved for the given token id.
    ///
    /// - Parameters:
    ///     - idToken: the associated token id for which to perform the refresh token exchange
    ///     - refreshToken: an existing, valid refresh token to be used for the refresh token exchange
    ///  - throws: ``SecureStoreError(.cantRetrieveKey)`` in case there was an error retrieving the
    ///  - throws: ``ServerError`` in case of a 400 response
    ///  - throws: ``RefreshTokenExchangeError.noInternet`` in case the network connection was either never
    ///      established, timed out or lost during the refresh token exchange.
    ///  - throws: a 
    /// - SeeAlso: ``TokenExchangeManaging/getUpdatedTokens(refreshToken:)`` on what a refresh token exchange entails.
    /// - SeeAlso: ``TokenStore`` on how to retrieve the saved tokens
    @MainActor
    func refreshTokens(idToken: String, refreshToken: String) async throws
    
    /// Ends the current session - removing and deleting session related data such as access and ID token
    func endCurrentSession()
    
    /// Completely removes all user session data (including the persistent session and Wallet data) from the device
    func clearAllSessionData(presentSystemLogOut: Bool) async throws
    
    /// Completely removes all user session data (including the persistent session and Wallet data) except analytics preferences
    func clearAppForLogin() async throws
    
    /// Asserts that, for a returning user, the ``persistentID`` is accessible.
    ///
    /// In case the ``persistentID`` is not accessible (e.g. cannot be decrypted), then all session data
    /// will be deleted for the user, a ``SecureStoreError(.cantDecryptData)`` is thrown and a
    /// ``systemLogUserOut`` notification is posted.
    ///
    /// - Note: The assertion is evaluated once per ``SessionManager`` instance.
    /// Any subsequent calls are effectively no-op. You need to create a ``SessionManager`` instance in order
    /// to evaluate the assertion again.
    /// - Postcondition: In case the assertion was evaluated succesfully, a follow-up call will not attempt
    /// to evaluate it again.
    /// - throws: ``SecureStoreError(.cantDecryptData)`` in case the ``persistentID`` was not accessible.
    /// - throws: ``PersistentSessionError(.cannotDeleteData)`` in case the user data was not succesfully deleted.
    /// - Remark: Since the ``SessionManager`` protocol does not constrain an implementation to an actor,
    /// it is the responsibility of each implementation to communicate its concurrency requirements in order to meet
    /// the postcondition.
    /// - SeeAlso: ``clearAllSessionData(presentSystemLogOut:)``
    ///
    func assertReturningUserCanLogin() async throws
}
