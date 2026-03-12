import AppIntegrity
import Authentication
import GDSAnalytics
@testable import OneLogin
import SecureStore
import XCTest

final class WebAuthenticationServiceTests: XCTestCase {
    var window: UIWindow!
    var mockSessionManager: MockSessionManager!
    var mockLoginSession: MockLoginSession!
    var mockAnalyticsService: MockAnalyticsService!
    var sut: WebAuthenticationService!

    @MainActor
    override func setUp() {
        super.setUp()

        window = .init()
        mockSessionManager = MockSessionManager()
        mockLoginSession = MockLoginSession(window: window)
        mockAnalyticsService = MockAnalyticsService()
        sut = WebAuthenticationService(sessionManager: mockSessionManager,
                                       session: mockLoginSession,
                                       analyticsService: mockAnalyticsService)
    }
    
    override func tearDown() {
        window = nil
        mockSessionManager = nil
        mockLoginSession = nil
        mockAnalyticsService = nil
        sut = nil
        
        super.tearDown()
    }
    
    private enum AuthenticationError: Error {
        case generic
    }
}

extension WebAuthenticationServiceTests {
    func test_loginError_userCancelled() async {
        mockSessionManager.errorFromStartSession = LoginError(reason: .userCancelled)
        
        do {
            try await sut.startWebSession()
        } catch {
            guard let error = error as? LoginError else {
                XCTFail("Error should be a LoginError")
                return
            }
            XCTAssertTrue(error == LoginError(reason: .userCancelled))
        }
        let userCancelledEvent = ButtonEvent(textKey: "back")
        XCTAssertEqual(mockAnalyticsService.eventsLogged, [userCancelledEvent.name.name])
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged, userCancelledEvent.parameters)
    }
    
    func test_tokenError_accessDenied() async {
        mockSessionManager.errorFromStartSession = LoginError(reason: .authorizationAccessDenied)
        
        do {
            try await sut.startWebSession()
        } catch {
            guard let error = error as? LoginError else {
                XCTFail("Error should be a LoginError")
                return
            }
            XCTAssertTrue(error == LoginError(reason: .authorizationAccessDenied))
        }
        XCTAssertTrue(mockSessionManager.didCallClearAllSessionData)
    }
    
    func test_authorizeError_accessDenied() async {
        mockSessionManager.errorFromStartSession = LoginError(
            reason: .invalidRedirectURL,
            underlyingReason: "access_denied: account deleted"
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
                    reason: .authorizationAccessDenied,
                    underlyingReason: "access_denied: account deleted"
                )
            )
        }
        XCTAssertTrue(mockSessionManager.didCallClearAllSessionData)
    }
    
    func test_loginError_invalidRedirectURL() async {
        mockSessionManager.errorFromStartSession = LoginError(reason: .invalidRedirectURL)
        
        do {
            try await sut.startWebSession()
        } catch {
            guard let error = error as? LoginError else {
                XCTFail("Error should be a LoginError")
                return
            }
            XCTAssertTrue(error == LoginError(reason: .invalidRedirectURL))
        }
        XCTAssertNotNil(mockAnalyticsService.crashesLogged)
    }
    
    func test_appIntegritySigningError() async {
        mockSessionManager.errorFromStartSession = AppIntegritySigningError(
            errorType: .publicKeyJWTError,
            errorDescription: "test description"
        )
        
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
        mockSessionManager.errorFromStartSession = FirebaseAppCheckError(
            .generic,
            reason: "test reason"
        )
        
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
        mockSessionManager.errorFromStartSession = ClientAssertionError(
            .invalidToken,
            reason: "test reason"
        )
        
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
        mockSessionManager.errorFromStartSession = ProofOfPossessionError(
            .cantGenerateAttestationPublicKeyJWK,
            reason: "test reason"
        )
        
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
        mockSessionManager.errorFromStartSession = SecureStoreErrorV2(.cantDecodeData)
        
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
        mockLoginSession.errorFromFinalise = AuthenticationError.generic
        
        do {
            let callbackURL = try XCTUnwrap(URL(string: "https://www.test.com"))
            try sut.handleUniversalLink(callbackURL)
            XCTFail("Method should throw an AuthenticationError.generic error")
        } catch let error as AuthenticationError {
            XCTAssertTrue(error == .generic)
        }
    }
}
