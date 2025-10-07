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
        mockSessionManager.errorFromStartSession = LoginErrorV2(reason: .userCancelled)
        
        do {
            try await sut.startWebSession()
        } catch {
            guard let error = error as? LoginErrorV2 else {
                XCTFail("Error should be a LoginError")
                return
            }
            XCTAssertTrue(error == LoginErrorV2(reason: .userCancelled))
        }
        let userCancelledEvent = ButtonEvent(textKey: "back")
        XCTAssertEqual(mockAnalyticsService.eventsLogged, [userCancelledEvent.name.name])
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged, userCancelledEvent.parameters)
    }
    
    func test_loginError_accessDenied() async {
        mockSessionManager.errorFromStartSession = LoginErrorV2(reason: .authorizationAccessDenied)
        
        do {
            try await sut.startWebSession()
        } catch {
            guard let error = error as? LoginErrorV2 else {
                XCTFail("Error should be a LoginError")
                return
            }
            XCTAssertTrue(error == LoginErrorV2(reason: .authorizationAccessDenied))
        }
        XCTAssertTrue(mockSessionManager.didCallClearAllSessionData)
    }
    
    func test_appIntegritySigningError() async {
        mockSessionManager.errorFromStartSession = AppIntegritySigningError(
            errorType: .publicKeyError,
            errorDescription: "test description"
        )
        
        do {
            try await sut.startWebSession()
        } catch {
            guard let error = error as? AppIntegritySigningError else {
                XCTFail("Error should be a SecureStoreError")
                return
            }
            XCTAssertTrue(error.errorType == .publicKeyError)
            XCTAssertNotNil(mockAnalyticsService.crashesLogged)
        }
    }
    
    func test_appIntegrityError_firebaseAppCheckError() async {
        mockSessionManager.errorFromStartSession = AppIntegrityError<FirebaseAppCheckError>(
            .generic,
            errorDescription: "test reason"
        )
        
        do {
            try await sut.startWebSession()
        } catch {
            guard let error = error as? AppIntegrityError<FirebaseAppCheckError> else {
                XCTFail("Error should be a SecureStoreError")
                return
            }
            XCTAssertTrue(error.errorType == .generic)
            XCTAssertNotNil(mockAnalyticsService.crashesLogged)
        }
    }
    
    func test_appIntegrityError_clientAssertionError() async {
        mockSessionManager.errorFromStartSession = AppIntegrityError<ClientAssertionError>(
            .invalidToken,
            errorDescription: "test reason"
        )
        
        do {
            try await sut.startWebSession()
        } catch {
            guard let error = error as? AppIntegrityError<ClientAssertionError> else {
                XCTFail("Error should be a SecureStoreError")
                return
            }
            XCTAssertTrue(error.errorType == .invalidToken)
            XCTAssertNotNil(mockAnalyticsService.crashesLogged)
        }
    }
    
    func test_appIntegrityError_proofOfPosessionError() async {
        mockSessionManager.errorFromStartSession = AppIntegrityError<ProofOfPossessionError>(
            .cantGeneratePublicKey,
            errorDescription: "test reason"
        )
        
        do {
            try await sut.startWebSession()
        } catch {
            guard let error = error as? AppIntegrityError<ProofOfPossessionError> else {
                XCTFail("Error should be a SecureStoreError")
                return
            }
            XCTAssertTrue(error.errorType == .cantGeneratePublicKey)
            XCTAssertNotNil(mockAnalyticsService.crashesLogged)
        }
    }
    
    func test_secureStoreError() async {
        mockSessionManager.errorFromStartSession = SecureStoreError.cantDecodeData
        
        do {
            try await sut.startWebSession()
        } catch {
            guard let error = error as? SecureStoreError else {
                XCTFail("Error should be a SecureStoreError")
                return
            }
            XCTAssertTrue(error == .cantDecodeData)
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
