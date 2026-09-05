// swiftlint:disable file_length
import AppIntegrity
import Authentication
import GDSAnalytics
import Logging
@testable import OneLogin
import SecureStore
import Testing
import WalletStore
import XCTest

final class WebAuthenticationServiceXCTests: XCTestCase {
    private enum AuthenticationError: Error {
        case generic
    }

    func test_loginError_userCancelled() async {
        let mockAnalyticsService = MockAnalyticsService()
        let sut: WebAuthenticationService = await .make(
            errorFromStartSession: LoginError(.userCancelled),
            mockAnalyticsService: mockAnalyticsService
        )
        
        do {
            try await sut.startWebSession()
        } catch {
            guard let error = error as? LoginError else {
                XCTFail("Error should be a LoginError")
                return
            }
            XCTAssertTrue(error == LoginError(.userCancelled))
        }
        let userCancelledEvent = ButtonEvent(textKey: "back")
        XCTAssertEqual(mockAnalyticsService.eventsLogged, [userCancelledEvent.name.name])
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged, userCancelledEvent.parameters)
    }
    
    func test_tokenError_accessDenied() async {
        let mockSessionManager = MockSessionManager()
        let sut: WebAuthenticationService = await .make(
            errorFromStartSession: LoginError(.authorizationAccessDenied),
            mockSessionManager: mockSessionManager
        )
        
        do {
            try await sut.startWebSession()
        } catch {
            guard let error = error as? LoginError else {
                XCTFail("Error should be a LoginError")
                return
            }
            XCTAssertTrue(error == LoginError(.authorizationAccessDenied))
        }
        XCTAssertTrue(mockSessionManager.didCallClearAllSessionData)
    }
    
    func test_authorizeError_accessDenied() async {
        let mockSessionManager = MockSessionManager()
        let sut: WebAuthenticationService = await .make(
            errorFromStartSession: LoginError(.invalidRedirectURL, reason: "access_denied: account deleted"),
            mockSessionManager: mockSessionManager
        )
        
        do {
            try await sut.startWebSession()
        } catch {
            guard let error = error as? LoginError else {
                XCTFail("Error should be a LoginError")
                return
            }
            XCTAssertEqual(
                error,
                LoginError(
                    .authorizationAccessDenied,
                    reason: "access_denied: account deleted"
                )
            )
        }
        XCTAssertTrue(mockSessionManager.didCallClearAllSessionData)
    }
    
    func test_loginError_invalidRedirectURL() async {
        let mockAnalyticsService = MockAnalyticsService()
        let sut: WebAuthenticationService = await .make(
            errorFromStartSession: LoginError(.invalidRedirectURL),
            mockAnalyticsService: mockAnalyticsService
        )

        do {
            try await sut.startWebSession()
        } catch {
            guard let error = error as? LoginError else {
                XCTFail("Error should be a LoginError")
                return
            }
            XCTAssertTrue(error == LoginError(.invalidRedirectURL))
        }
        XCTAssertNotNil(mockAnalyticsService.crashesLogged)
    }
    
    func test_appIntegritySigningError() async {
        let mockAnalyticsService = MockAnalyticsService()
        let sut: WebAuthenticationService = await .make(
            errorFromStartSession: AppIntegritySigningError(errorType: .publicKeyJWTError, errorDescription: "test description"),
            mockAnalyticsService: mockAnalyticsService
        )

        do {
            try await sut.startWebSession()
        } catch {
            guard let error = error as? AppIntegritySigningError else {
                XCTFail("Error should be a AppIntegritySigningError")
                return
            }
            XCTAssertTrue(error.errorType == .publicKeyJWTError)
            XCTAssertNotNil(mockAnalyticsService.crashesLogged)
        }
    }
    
    func test_appIntegrityError_firebaseAppCheckError() async {
        let mockAnalyticsService = MockAnalyticsService()
        let sut: WebAuthenticationService = await .make(
            errorFromStartSession: FirebaseAppCheckError(.generic, reason: "test reason"),
            mockAnalyticsService: mockAnalyticsService
        )
        
        do {
            try await sut.startWebSession()
        } catch {
            guard let error = error as? FirebaseAppCheckError else {
                XCTFail("Error should be a FirebaseAppCheckError")
                return
            }
            XCTAssertTrue(error.kind == .generic)
            XCTAssertNotNil(mockAnalyticsService.crashesLogged)
        }
    }
    
    func test_appIntegrityError_clientAssertionError() async {
        let mockAnalyticsService = MockAnalyticsService()
        let sut: WebAuthenticationService = await .make(
            errorFromStartSession: ClientAssertionError(.invalidToken, reason: "test reason"),
            mockAnalyticsService: mockAnalyticsService
        )
        
        do {
            try await sut.startWebSession()
        } catch {
            guard let error = error as? ClientAssertionError else {
                XCTFail("Error should be a ClientAssertionError")
                return
            }
            XCTAssertTrue(error.kind == .invalidToken)
            XCTAssertNotNil(mockAnalyticsService.crashesLogged)
        }
    }
    
    func test_appIntegrityError_proofOfPosessionError() async {
        let mockAnalyticsService = MockAnalyticsService()
        let sut: WebAuthenticationService = await .make(
            errorFromStartSession: ProofOfPossessionError(.cantGenerateAttestationPublicKeyJWK, reason: "test reason"),
            mockAnalyticsService: mockAnalyticsService
        )

        
        do {
            try await sut.startWebSession()
        } catch {
            guard let error = error as? ProofOfPossessionError else {
                XCTFail("Error should be a ProofOfPossessionError")
                return
            }
            XCTAssertTrue(error.kind == .cantGenerateAttestationPublicKeyJWK)
            XCTAssertNotNil(mockAnalyticsService.crashesLogged)
        }
    }
    
    func test_secureStoreError() async {
        let mockAnalyticsService = MockAnalyticsService()
        let sut: WebAuthenticationService = await .make(
            errorFromStartSession: SecureStoreError(.cantDecodeData),
            mockAnalyticsService: mockAnalyticsService
        )

        do {
            try await sut.startWebSession()
        } catch {
            guard let error = error as? SecureStoreError else {
                XCTFail("Error should be a SecureStoreError")
                return
            }
            XCTAssertTrue(error.kind == .cantDecodeData)
            XCTAssertNotNil(mockAnalyticsService.crashesLogged)
        }
    }
    
    @MainActor
    func test_handleUniversalLink_catchAllError() throws {
        let sut: WebAuthenticationService = .make(errorFromFinalise: AuthenticationError.generic)
        
        do {
            let callbackURL = try XCTUnwrap(URL(string: "https://www.test.com"))
            try sut.handleUniversalLink(callbackURL)
            XCTFail("Method should throw an AuthenticationError.generic error")
        } catch let error as AuthenticationError {
            XCTAssertTrue(error == .generic)
        }
    }
}

struct WebAuthenticationServiceTests {
    /// GIVEN I am "a returning user", who is "NOT authenticated" due to a `nil` `persistentId`
    /// AND `WalletSessionBoundData` throws `WalletStoreError(.failedToDeleteProofKeys)` in case`clearAllSessionData` is called
    /// WHEN I start a web session
    /// THEN an error is logged as a crash in analytics
    /// AND the error is thrown
    @Test
    func test_startWebSession_throws_cannotDeleteData() async throws {
        let mockAnalyticsService = MockAnalyticsService()

        let walletSessionData = WalletSessionBoundDataStub(clearSessionDataAsFunction: {
            throw WalletStoreError(.failedToDeleteProofKeys)
        })
        
        let sessionManager: PersistentSessionManager = try .makeReturningUnauthenticatedUser(
            mockAnalyticsService: mockAnalyticsService,
            walletSessionData: walletSessionData
        )
        
        let sut: WebAuthenticationService = await .make(
            sessionManager: sessionManager,
            mockAnalyticsService: mockAnalyticsService
        )
        
        let error = await #expect(throws: PersistentSessionError.self) {
            try await sut.startWebSession()
        }
        
        #expect(error?.kind == .cannotDeleteData)
        #expect(mockAnalyticsService.crashesLogged.count == 1)
    }
    
    /// GIVEN I am "a returning user", who is "NOT enrolling" and "NOT authenticated" due to a `nil` `expiryDate`
    /// AND `SecureStoreService` throws `SecureStoreError(.cantRetrieveKey)` in case`saveItem` is called as part of `PersistentSessionManager.saveAuthSession()`
    /// WHEN I start a web session
    /// THEN an error is logged as a crash in analytics
    /// AND the error is thrown
    @Test
    func test_startWebSession_throws_cannotRetrieveKey() async throws {
        let mockAnalyticsService = MockAnalyticsService()

        let mockEncryptedStore = MockSecureStoreService()
        
        let sessionManager: PersistentSessionManager = try .makeReturningNonEnrollingUnauthenticatedUserWithoutSavedExpiryDate(
            mockAnalyticsService: mockAnalyticsService,
            mockEncryptedStore: mockEncryptedStore
        )
        
        mockEncryptedStore.errorFromSaveItem = SecureStoreError(.cantRetrieveKey)
        
        let sut: WebAuthenticationService = await .make(
            sessionManager: sessionManager,
            mockAnalyticsService: mockAnalyticsService
        )
        
        let error = await #expect(throws: SecureStoreError.self) {
            try await sut.startWebSession(appIntegrityProvider: AppIntegrityProviderStub())
        }
        
        #expect(error?.kind == .cantRetrieveKey)
        
        #expect(mockAnalyticsService.crashesLogged.count == 1)
    }
    
    @Test
    func test_startWebSession_success() async throws {
        let sessionManager: PersistentSessionManager = try .make()
        let sut: WebAuthenticationService = await .make(sessionManager: sessionManager)
        
        await #expect(throws: Never.self) {
            try await sut.startWebSession(appIntegrityProvider: AppIntegrityProviderStub())
        }
    }
    
    @Test
    func test_loginError_logged_by_default() async {
        let mockAnalyticsService = MockAnalyticsService()
        let anyError = LoginError(.generic)
        
        let sut: WebAuthenticationService = await .make(errorFromStartSession: anyError,
                                                        mockAnalyticsService: mockAnalyticsService)
        
        let error = await #expect(throws: LoginError.self) {
            try await sut.startWebSession()
        }
    
        #expect(error == anyError)
        #expect(mockAnalyticsService.crashesLogged.count == 1)
    }

    /// This is a case where a as part of instantiating a `KeyManagerService`, a new set of keys is created
    /// that is tied to the Secure Enclave (i.e. `kSecAttrTokenID: kSecAttrTokenIDSecureEnclave`).
    ///
    /// A SE key pair provides strong guarantees so that:
    /// * It is never exported to a backup
    /// * The key pair is deleted as soon as the device is erased
    ///
    /// In this case:
    /// 1. a backup from an existing device, with previously encrypted data (i.e. , AttestationJWT)
    /// 2. a restore on the device is performed
    /// 3. the data is restored
    /// 4. the key is not restored
    ///
    /// When attempting to **decrypt** the data, an `errSecParam` (aka -50) will be thrown
    @Test("""
         GIVEN I am "a returning user", who is "NOT enrolling" and "NOT authenticated" due to a `nil` `expiryDate`
         AND `AttestationStorage` is not expired throws `SecureStoreError(.cantDecryptData)` with an
             in case `tokenHeaders` are required as part of `LoginSession.performLoginFlow(configuration:)`
         WHEN I start a web session, a login will be performed
         THEN an error is logged as a crash in analytics
         AND the error is thrown
        """)
    func test_errorFromAttestationJWT_onReturningUser() async throws {
        let mockAnalyticsService = MockAnalyticsService()

        let sessionManager: PersistentSessionManager = try .makeReturningNonEnrollingUnauthenticatedUserWithoutSavedExpiryDate()

        let sut: WebAuthenticationService = await .make(
            sessionManager: sessionManager,
            mockLoginSession: MockAppAuthSession(performLoginFlowAsFunction: { configuration in
                _ = try await configuration.tokenHeaders()
                return try MockTokenResponse().getJSONData()
            }),
            mockAnalyticsService: mockAnalyticsService
        )

        let errorFromAttestationJWT = SecureStoreError(.cantDecryptData,
                                                       originalError: NSError(domain: NSOSStatusErrorDomain, code: -50))

        let error = await #expect(throws: SecureStoreError.self) {
            try await sut.startWebSession(appIntegrityProvider: FirebaseAppIntegrityService.makeNonExpired(errorFromAttestationJWT: errorFromAttestationJWT))
        }

        #expect(error?.kind == .cantDecryptData)

        let originalError = try #require(error?.originalError as? NSError)
        #expect(originalError.code == errSecParam)
        #expect(originalError.code == -50)

        #expect(mockAnalyticsService.crashesLogged.count == 1)
    }
    
    /// This is a case where a as part of instantiating a `KeyManagerService`, a new set of keys is created
    /// that is tied to the Secure Enclave (i.e. `kSecAttrTokenID: kSecAttrTokenIDSecureEnclave`).
    ///
    /// A SE key pair provides strong guarantees so that:
    /// * It is never exported to a backup
    /// * The key pair is deleted as soon as the device is erased
    ///
    /// In this case:
    /// 1. a backup from an existing device, with previously encrypted data (i.e. , AttestationJWT)
    /// 2. a restore on the device is performed
    /// 3. the data is restored
    /// 4. the key is not restored
    ///
    /// When attempting to **decrypt** the data, an `errSecParam` (aka -50) will be thrown
    @Test("""
         GIVEN I am "a new user", who is "NOT enrolling"
         AND `AttestationStorage` is not expired throws `SecureStoreError(.cantDecryptData)` with an
             in case `tokenHeaders` are required as part of `LoginSession.performLoginFlow(configuration:)`
         WHEN I start a web session, a login will be performed
         THEN an error is logged as a crash in analytics
         AND the error is thrown
        """)
    func test_errorFromAttestationJWT_onNewUser() async throws {
        let mockAnalyticsService = MockAnalyticsService()

        let sessionManager: PersistentSessionManager = try .make()

        let sut: WebAuthenticationService = await .make(
            sessionManager: sessionManager,
            mockLoginSession: MockAppAuthSession(performLoginFlowAsFunction: { configuration in
                _ = try await configuration.tokenHeaders()
                return try MockTokenResponse().getJSONData()
            }),
            mockAnalyticsService: mockAnalyticsService
        )

        let errorFromAttestationJWT = SecureStoreError(.cantDecryptData,
                                                       originalError: NSError(domain: NSOSStatusErrorDomain, code: -50))

        let error = await #expect(throws: SecureStoreError.self) {
            try await sut.startWebSession(appIntegrityProvider: FirebaseAppIntegrityService.makeNonExpired(errorFromAttestationJWT: errorFromAttestationJWT))
        }

        #expect(error?.kind == .cantDecryptData)

        let originalError = try #require(error?.originalError as? NSError)
        #expect(originalError.code == errSecParam)
        #expect(originalError.code == -50)

        #expect(mockAnalyticsService.crashesLogged.count == 1)
    }
}

struct WalletSessionBoundDataStub: SessionBoundData {
    
    final class UserSessionData {
        fileprivate var storage: [AnyHashable: Sendable]
        
        var isEmpty: Bool {
            self.storage.isEmpty
        }

        init(storage: [AnyHashable: Sendable] = [:]) {
            self.storage = storage
        }
        
        subscript(key: AnyHashable) -> Sendable? {
            get {
                storage[key]
            }
            set {
                storage[key] = newValue
            }
        }
    }

    static func stubWalletData(_ walletData: [AnyHashable: Sendable]) -> (mockWalletSessionBound: WalletSessionBoundDataStub, walletData: UserSessionData) {
        let walletData = UserSessionData(storage: walletData)
        
        return (mockWalletSessionBound: WalletSessionBoundDataStub(
            clearSessionDataAsFunction: clearSessionData(walletData: walletData)),
                walletData: walletData)
    }
    
    static func clearSessionData(walletData: UserSessionData) -> ClearSessionDataAsFunction {
        return {
            walletData.storage = [:]
        }
    }

    typealias ClearSessionDataAsFunction = () async throws -> Void
    
    var clearSessionDataAsFunction: ClearSessionDataAsFunction = { }

    func clearSessionData() async throws {
        return try await self.clearSessionDataAsFunction()
    }
}

@MainActor
extension WebAuthenticationService {
    static func make(sessionManager: SessionManager = MockSessionManager(),
                     mockLoginSession: LoginSession? = nil,
                     mockAnalyticsService: MockAnalyticsService = MockAnalyticsService()) -> WebAuthenticationService {
        
        let mockLoginSession = mockLoginSession ?? MockAppAuthSession()
        
        return WebAuthenticationService(sessionManager: sessionManager,
                                        session: mockLoginSession,
                                        analyticsService: mockAnalyticsService)
    }
    
    static func make(errorFromStartSession error: Error,
                     mockSessionManager: MockSessionManager = MockSessionManager(),
                     mockAnalyticsService: MockAnalyticsService = MockAnalyticsService()) -> WebAuthenticationService {
        mockSessionManager.errorFromStartSession = error
        
        return .make(sessionManager: mockSessionManager, mockAnalyticsService: mockAnalyticsService)
    }
    
    static func make(errorFromFinalise error: Error) -> WebAuthenticationService {
        let window = UIWindow()
        let mockLoginSession = MockLoginSession(window: window)
        mockLoginSession.errorFromFinalise = error
        
        return .make(mockLoginSession: mockLoginSession)
    }
}
