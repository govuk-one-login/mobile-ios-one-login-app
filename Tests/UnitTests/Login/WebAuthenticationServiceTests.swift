import AppIntegrity
import Authentication
import Common
import GDSAnalytics
import Logging
@testable import OneLogin
import SecureStore
import Testing
import Wallet
import XCTest

final class WebAuthenticationServiceXCTests: XCTestCase {
   
    private enum AuthenticationError: Error {
        case generic
    }

    func test_loginError_userCancelled() async {
        let mockAnalyticsService = MockAnalyticsService()
        let sut: WebAuthenticationService = await .make(errorFromStartSession: LoginError(.userCancelled), mockAnalyticsService: mockAnalyticsService)
        
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
        let sut: WebAuthenticationService = await .make(errorFromStartSession: LoginError(.authorizationAccessDenied), mockSessionManager: mockSessionManager)
        
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
        let sut: WebAuthenticationService = await .make(errorFromStartSession: LoginError(
            .invalidRedirectURL,
            reason: "access_denied: account deleted"
        ), mockSessionManager: mockSessionManager)

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
        let sut: WebAuthenticationService = await .make(errorFromStartSession: LoginError(.invalidRedirectURL),
                                                        mockAnalyticsService: mockAnalyticsService)

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
        let sut: WebAuthenticationService = await .make(errorFromStartSession: AppIntegritySigningError(
            errorType: .publicKeyJWTError,
            errorDescription: "test description"
        ), mockAnalyticsService: mockAnalyticsService)

        do {
            try await sut.startWebSession()
        } catch {
            guard let error = error as? AppIntegritySigningError else {
                XCTFail("Error should be a SecureStoreError")
                return
            }
            XCTAssertTrue(error.errorType == .publicKeyJWTError)
            XCTAssertNotNil(mockAnalyticsService.crashesLogged)
        }
    }
    
    func test_appIntegrityError_firebaseAppCheckError() async {
        let mockAnalyticsService = MockAnalyticsService()
        let sut: WebAuthenticationService = await .make(errorFromStartSession: FirebaseAppCheckError(
            .generic,
            reason: "test reason"
        ), mockAnalyticsService: mockAnalyticsService)
        
        do {
            try await sut.startWebSession()
        } catch {
            guard let error = error as? FirebaseAppCheckError else {
                XCTFail("Error should be a SecureStoreError")
                return
            }
            XCTAssertTrue(error.kind == .generic)
            XCTAssertNotNil(mockAnalyticsService.crashesLogged)
        }
    }
    
    func test_appIntegrityError_clientAssertionError() async {
        let mockAnalyticsService = MockAnalyticsService()
        let sut: WebAuthenticationService = await .make(errorFromStartSession:
            ClientAssertionError(
            .invalidToken,
            reason: "test reason"
        ), mockAnalyticsService: mockAnalyticsService)

        do {
            try await sut.startWebSession()
        } catch {
            guard let error = error as? ClientAssertionError else {
                XCTFail("Error should be a SecureStoreError")
                return
            }
            XCTAssertTrue(error.kind == .invalidToken)
            XCTAssertNotNil(mockAnalyticsService.crashesLogged)
        }
    }
    
    func test_appIntegrityError_proofOfPosessionError() async {
        let mockAnalyticsService = MockAnalyticsService()
        let sut: WebAuthenticationService = await .make(errorFromStartSession: ProofOfPossessionError(
            .cantGenerateAttestationPublicKeyJWK,
            reason: "test reason"
        ), mockAnalyticsService: mockAnalyticsService)

        
        do {
            try await sut.startWebSession()
        } catch {
            guard let error = error as? ProofOfPossessionError else {
                XCTFail("Error should be a SecureStoreError")
                return
            }
            XCTAssertTrue(error.kind == .cantGenerateAttestationPublicKeyJWK)
            XCTAssertNotNil(mockAnalyticsService.crashesLogged)
        }
    }
    
    func test_secureStoreError() async {
        let mockAnalyticsService = MockAnalyticsService()
        let sut: WebAuthenticationService = await .make(errorFromStartSession: SecureStoreErrorV2(.cantDecodeData),
                                                        mockAnalyticsService: mockAnalyticsService)

        do {
            try await sut.startWebSession()
        } catch {
            guard let error = error as? SecureStoreErrorV2 else {
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
    /// AND `WalletSessionBoundData` throws `WalletError(.failedToDeleteProofKeys)` when `clearAllSessionData` is called
    /// WHEN I start a web session
    /// THEN an error is logged as a crash in analytics
    /// AND the error is thrown
    @Test func test_startWebSession_throws_cannotDeleteData() async throws {
        let mockAnalyticsService = MockAnalyticsService()

        let walletSessionData = WalletSessionBoundDataStub( clearSessionDataAsFunction: {
            throw WalletError(.failedToDeleteProofKeys)
        })
        
        let sessionManager: PersistentSessionManager =
            try .makeReturningUnauthenticatedUser(mockAnalyticsService: mockAnalyticsService,
                                                  walletSessionData: walletSessionData)
        
        let sut: WebAuthenticationService = await .make(sessionManager: sessionManager,
                                                        mockAnalyticsService: mockAnalyticsService)
        
        let error = await #expect(throws: PersistentSessionError.self) {
            try await sut.startWebSession()
        }
        
        #expect(error?.kind == .cannotDeleteData)
        #expect(mockAnalyticsService.crashesLogged.count == 1)
    }
}

struct WalletSessionBoundDataStub: SessionBoundData {
    
    enum ClearSessionDataResult {
        case failedToDeleteProofKeys
        case success
    }
    
    typealias ClearSessionDataAsFunction = () async throws -> Void
    
    var clearSessionDataAsFunction: ClearSessionDataAsFunction

    func clearSessionData() async throws {
        return try await self.clearSessionDataAsFunction()
    }
}

struct MockAnalyticsPreferenceStoreExpectation: AnalyticsPreferenceStore, SessionBoundData {
    
    typealias ClearSessionDataAsFunction = () async throws -> Void
    
    var clearSessionDataAsFunction: ClearSessionDataAsFunction

    var hasAcceptedAnalytics: Bool? = false
    
    func stream() -> AsyncStream<Bool> {
        var booleans = sequence(first: true) { _ in
            Bool.random()
        }.makeIterator()
        
        return AsyncStream {
            booleans.next()
        }
    }
    
    func clearSessionData() async throws {
        try await self.clearSessionDataAsFunction()
    }
}

extension WebAuthenticationService {
    
    @MainActor
    static func make(window: UIWindow? = nil,
                     sessionManager: SessionManager = MockSessionManager(),
                     mockLoginSession: MockLoginSession? = nil,
                     mockAnalyticsService: MockAnalyticsService = MockAnalyticsService()) -> WebAuthenticationService {
        
        let window = window ?? UIWindow()
        let mockLoginSession = mockLoginSession ?? MockLoginSession(window: window)
        
        return WebAuthenticationService(sessionManager: sessionManager,
                                        session: mockLoginSession,
                                        analyticsService: mockAnalyticsService)
    }
    
    @MainActor
    static func make(errorFromStartSession error: Error,
                     mockSessionManager: MockSessionManager = MockSessionManager(),
                     mockAnalyticsService: MockAnalyticsService = MockAnalyticsService()) -> WebAuthenticationService {
        mockSessionManager.errorFromStartSession = error
        
        return .make(sessionManager: mockSessionManager, mockAnalyticsService: mockAnalyticsService)
    }
    
    @MainActor
    static func make(errorFromFinalise error: Error) -> WebAuthenticationService {
        let window = UIWindow()
        let mockLoginSession = MockLoginSession(window: window)
        mockLoginSession.errorFromFinalise = error

        
        return .make(window: window, mockLoginSession: mockLoginSession)
    }
}

extension PersistentSessionManager {
    
    
    /// Creates a `PersistentSessionManager` with the following conditions:
    /// * `persistentID = nil` i.e. not stored in the `encryptedStore`
    /// * `isReturningUser = true`
    /// *  `walletSDK.isEmpty = true`
    ///
    /// A call to `startAuthSession(:using:)` assumes this is "a returning user" that cannot authenticate due to
    /// the missing `persistendId` results  in call to `clearAllSessionData` to delete my session & Wallet data.
    static func makeReturningUnauthenticatedUser(mockAnalyticsService: MockAnalyticsService = MockAnalyticsService(),
                                                 mockEncryptedStore: MockSecureStoreService = MockSecureStoreService(),
                                                 mockUnprotectedStore: (any DefaultsStoring & SessionBoundData) = MockDefaultsStore(),
                                                 walletSessionData: SessionBoundData,
                                                 analyticsPreferenceStore: (any AnalyticsPreferenceStore & SessionBoundData) = MockAnalyticsPreferenceStore()
    ) throws -> PersistentSessionManager {
        
        mockUnprotectedStore.set(
            true,
            forKey: OLString.returningUser
        )
        
        let walletSDK = MockWalletSDKWrapper()
        walletSDK.isEmpty = true
        
        return try .make(analyticsService: mockAnalyticsService,
                         refreshTokenExchangeManager: MockRefreshTokenExchangeManager(),
                         serialTaskQueue: SerialTaskQueue(),
                         analyticsPreferenceStore: analyticsPreferenceStore,
                         encryptedStore: mockEncryptedStore,
                         unprotectedStore: mockUnprotectedStore,
                         walletSDK: walletSDK,
                         walletSessionData: walletSessionData)
    }
    
}
