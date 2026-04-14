// swiftlint:disable file_length
import AppIntegrity
import Authentication
import GDSCommon
@testable import OneLogin
import SecureStore
import XCTest

extension LoginCoordinator {
    
    static func make(mockNavigationController: UINavigationController = UINavigationController(), mockSessionManager: SessionManager = MockSessionManager()) -> LoginCoordinator {
        
        let appWindow = UIWindow()
        let mockAnalyticsService = MockAnalyticsService()
        let mockNetworkMonitor = MockNetworkMonitor()
        let mockAuthenticationService = MockAuthenticationService(sessionManager: mockSessionManager)
        appWindow.rootViewController = mockNavigationController
        appWindow.makeKeyAndVisible()

        return LoginCoordinator(appWindow: appWindow,
                               root: mockNavigationController,
                               analyticsService: mockAnalyticsService,
                               sessionManager: mockSessionManager,
                               networkMonitor: mockNetworkMonitor,
                               authService: mockAuthenticationService,
                               sessionState: .notLoggedIn,
                               serviceState: nil)
        
    }
}

final class LoginCoordinatorTests: XCTestCase {
    var appWindow: UIWindow!
    var navigationController: UINavigationController!
    var mockAnalyticsService: MockAnalyticsService!
    var mockSessionManager: MockSessionManager!
    var mockNetworkMonitor: NetworkMonitoring!
    var mockAuthenticationService: MockAuthenticationService!
    var sut: LoginCoordinator!
    
    @MainActor
    override func setUp() {
        super.setUp()
        
        appWindow = .init()
        navigationController = .init()
        mockAnalyticsService = MockAnalyticsService()
        mockSessionManager = MockSessionManager()
        mockNetworkMonitor = MockNetworkMonitor()
        mockAuthenticationService = MockAuthenticationService(sessionManager: mockSessionManager)
        appWindow.rootViewController = navigationController
        appWindow.makeKeyAndVisible()
        sut = LoginCoordinator(appWindow: appWindow,
                               root: navigationController,
                               analyticsService: mockAnalyticsService,
                               sessionManager: mockSessionManager,
                               networkMonitor: mockNetworkMonitor,
                               authService: mockAuthenticationService,
                               sessionState: .notLoggedIn,
                               serviceState: nil)
    }
    
    override func tearDown() {
        appWindow = nil
        navigationController = nil
        mockAnalyticsService = nil
        mockSessionManager = nil
        mockNetworkMonitor = nil
        mockAuthenticationService = nil
        sut = nil
        
        super.tearDown()
    }
    
    @MainActor
    func reauthLogin() {
        mockSessionManager.isReturningUser = true
        sut = LoginCoordinator(appWindow: appWindow,
                               root: navigationController,
                               analyticsService: mockAnalyticsService,
                               sessionManager: mockSessionManager,
                               networkMonitor: mockNetworkMonitor,
                               authService: mockAuthenticationService,
                               sessionState: .expired,
                               serviceState: nil)
    }
    
    @MainActor
    func given(errorFromStartSession: Error, when: (LoginCoordinator) -> Void) throws -> GDSErrorViewModelV3 {
        let startAuthSessionExpectation = expectation(description: #function)
        let pushViewControllerExpectation = self.expectation(description: #function)

        // GIVEN the authentication session returns a sessionMismatch error
        let mockNavigationController = MockNavigationControllerExpectation(pushViewControllerAsFunction: { _, _ in   pushViewControllerExpectation.fulfill()
        })
        let mockSessionManager = MockSessionManager()
        let mockSessionManagerExpectation = MockSessionManagerExpectation(sessionManager: mockSessionManager, didStartAuthSessionAsFunction: { _, _ in
            startAuthSessionExpectation.fulfill()
        })
        
        mockSessionManager.errorFromStartSession = errorFromStartSession
        let sut: LoginCoordinator = .make(mockNavigationController: mockNavigationController, mockSessionManager: mockSessionManagerExpectation)

        when(sut)

        wait(for: [startAuthSessionExpectation, pushViewControllerExpectation], timeout: 10)
        XCTAssertTrue(mockSessionManager.didCallStartSession)
        
        let vc = try XCTUnwrap(mockNavigationController.topViewController as? GDSErrorScreen)
        
        return vc.viewModel
    }
    
    @MainActor
    func given(errorFromStartSession: Error, repeats count: Int, when:(LoginCoordinator) -> Void, then: (_ count: Int, _ topViewController: UIViewController?) throws -> Void) rethrows {
        let mockNavigationController = MockNavigationControllerExpectation()
        let mockSessionManager = MockSessionManager()
        mockSessionManager.errorFromStartSession = errorFromStartSession
        let mockSessionManagerExpectation = MockSessionManagerExpectation(sessionManager: mockSessionManager)
        
        let sut: LoginCoordinator = .make(mockNavigationController: mockNavigationController, mockSessionManager: mockSessionManagerExpectation)

        for count in 1...count {
            let startAuthSessionExpectation = expectation(description: #function)
            mockSessionManagerExpectation.didStartAuthSessionAsFunction = { _, _ in
                startAuthSessionExpectation.fulfill()
            }
            
            mockSessionManager.didCallStartSession = false
            
            let pushViewControllerExpectation = self.expectation(description: #function)
            mockNavigationController.pushViewControllerAsFunction = { _, _ in
                pushViewControllerExpectation.fulfill()
            }
            
            when(sut)
            
            wait(for: [startAuthSessionExpectation, pushViewControllerExpectation], timeout: 10)
            XCTAssertTrue(mockSessionManager.didCallStartSession)
            
            try then(count, mockNavigationController.topViewController)
        }
    }
}

enum AuthenticationError: Error {
    case generic
}

extension LoginCoordinatorTests {
    // MARK: Login
    @MainActor
    func test_start() {
        // WHEN the LoginCoordinator is started
        sut.start()
        // THEN the visible view controller should be the IntroViewController
        XCTAssertTrue(sut.root.viewControllers.count == 1)
        XCTAssertTrue(sut.root.topViewController is IntroViewController)
    }
    
    @MainActor
    func test_start_reauth() throws {
        // WHEN the LoginCoordinator is started in a reauth flow
        reauthLogin()
        sut.start()
        // THEN the user sees the session expired screen
        XCTAssertTrue(sut.root.viewControllers.count == 1)
        // THEN the visible view controller should be the GDSInformationViewController
        let screen = try XCTUnwrap(sut.root.topViewController as? GDSInformationViewController)
        // THEN the visible view controller's view model should be the SignOutWarningViewModel
        XCTAssertTrue(screen.viewModel is SignOutWarningViewModel)
    }
    
    @MainActor
    func test_authenticate_launchAuthenticationService() {
        let expectation = expectation(description: #function)
        let mockSessionManager = MockSessionManager()
        let mockSessionManagerExpectation = MockSessionManagerExpectation(sessionManager: mockSessionManager, didStartAuthSessionAsFunction: { _, _ in
            expectation.fulfill()
        })
        
        let sut: LoginCoordinator = .make(mockSessionManager: mockSessionManagerExpectation)
        
        // WHEN the LoginCoordinator's authenticate method is called
        sut.authenticate()
        // THEN the AuthenticationService should be launched
        wait(for: [expectation], timeout: 20)
        XCTAssertTrue(mockSessionManager.didCallStartSession)
    }
    
    @MainActor
    func test_authenticate_noNetwork() throws {
        // GIVEN the network is not connected
        mockNetworkMonitor.isConnected = false
        // WHEN the LoginCoordinator's authenticate method is called
        sut.authenticate()
        // THEN the visible view controller should be the GDSErrorScreen
        let errorScreen = try XCTUnwrap(sut.root.topViewController as? GDSErrorScreen)
        // THEN the visible view controller's view model should be the NetworkConnectionErrorViewModel
        XCTAssertTrue(errorScreen.viewModel is NetworkConnectionErrorViewModel)
    }
    
    @MainActor
    func test_launchAuthenticationService() {
        let expectation = self.expectation(description: #function)
        let mockSessionManager = MockSessionManager()
        let mockSessionManagerExpectation = MockSessionManagerExpectation(sessionManager: mockSessionManager,
                                                                          didStartAuthSessionAsFunction: { _, _ in
            expectation.fulfill()
        })
        
        let sut: LoginCoordinator = .make(mockSessionManager: mockSessionManagerExpectation)
        
        // WHEN the LoginCoordinator's launchAuthenticationService method is called
        sut.launchAuthenticationService()
        // THEN the AuthenticationService should be launched
        wait(for: [expectation], timeout: 20)
        XCTAssertTrue(mockSessionManager.didCallStartSession)
    }
    
    @MainActor
    func test_launchAuthenticationService_sessionMismatch() throws {
        // GIVEN the authentication session returns a sessionMismatch error
        let viewModel = try given(errorFromStartSession: PersistentSessionError(.sessionMismatch), when: { sut in
            // WHEN the LoginCoordinator's launchAuthenticationService method is called
            sut.launchAuthenticationService()
        })

        // THEN the visible view controller's view model should be the DataDeletedWarningViewModel
        XCTAssertTrue(viewModel is DataDeletedWarningViewModel)
    }
    
    @MainActor
    func test_launchAuthenticationService_cannotDeleteData() throws {
        // GIVEN the authentication session returns a cannotDeleteData error
        let errorFromStartSession = PersistentSessionError(.cannotDeleteData,
                                                                          originalError: MockWalletError.cantDelete)
        let viewModel = try given(errorFromStartSession: errorFromStartSession, when: { sut in
            // WHEN the LoginCoordinator's launchAuthenticationService method is called
            sut.launchAuthenticationService()
        })

        // THEN the visible view controller's view model should be the RecoverableLoginErrorViewModel
        XCTAssertTrue(viewModel is RecoverableLoginErrorViewModel)
    }
    
    @MainActor
    func test_launchAuthenticationService_idTokenNotStored() throws {
        // GIVEN the authentication session returns a idTokenNotStored error
        let viewModel = try given(errorFromStartSession: PersistentSessionError(.idTokenNotStored), when: { sut in
            // WHEN the LoginCoordinator's launchAuthenticationService method is called
            sut.launchAuthenticationService()
        })

        // THEN the visible view controller's view model should be the GenericErrorViewModel
        XCTAssertTrue(viewModel is GenericErrorViewModel)

    }
    
    @MainActor
    func test_launchAuthenticationService_accessDenied() throws {
        // GIVEN the authentication session returns an access denied error
        let viewModel = try given(errorFromStartSession: LoginError(reason: .authorizationAccessDenied), when: { sut in
            // WHEN the LoginCoordinator's launchAuthenticationService method is called
            sut.launchAuthenticationService()
        })

        // THEN the visible view controller's view model should be the DataDeletedWarningViewModel
        XCTAssertTrue(viewModel is DataDeletedWarningViewModel)
    }
    
    @MainActor
    func test_launchAuthenticationService_network() throws {
        // GIVEN the authentication session returns a network error
        let viewModel = try given(errorFromStartSession: LoginError(reason: .network), when: { sut in
            // WHEN the LoginCoordinator's launchAuthenticationService method is called
            sut.launchAuthenticationService()
        })

        // THEN the visible view controller's view model should be the NetworkConnectionErrorViewModel
        XCTAssertTrue(viewModel is NetworkConnectionErrorViewModel)
    }
    
    @MainActor
    func test_launchAuthenticationService_authInvalidRequest() throws {
        // GIVEN the authentication session returns an invalidRequest error
        let viewModel = try given(errorFromStartSession: LoginError(reason: .authorizationInvalidRequest), when: { sut in
            // WHEN the LoginCoordinator's launchAuthenticationService method is called
            sut.launchAuthenticationService()
        })

        // THEN the visible view controller's view model should be the UnrecoverableLoginErrorViewModel
        XCTAssertTrue(viewModel is UnrecoverableLoginErrorViewModel)
    }
    
    @MainActor
    func test_launchAuthenticationService_authUnauthorizedClient() throws {
        // GIVEN the authentication session returns an unauthorizedClient error
        let viewModel = try given(errorFromStartSession: LoginError(reason: .authorizationUnauthorizedClient), when: { sut in
            // WHEN the LoginCoordinator's launchAuthenticationService method is called
            sut.launchAuthenticationService()
        })

        // THEN the visible view controller's view model should be the UnrecoverableLoginErrorViewModel
        XCTAssertTrue(viewModel is UnrecoverableLoginErrorViewModel)
    }
    
    @MainActor
    func test_launchAuthenticationService_unsupportedResponse() throws {
        // GIVEN the authentication session returns an unsupportedResponseType error
        mockSessionManager.errorFromStartSession = LoginError(reason: .authorizationUnsupportedResponseType)
        let viewModel = try given(errorFromStartSession: LoginError(reason: .authorizationUnsupportedResponseType), when: { sut in
            // WHEN the LoginCoordinator's launchAuthenticationService method is called
            sut.launchAuthenticationService()
        })

        // THEN the visible view controller's view model should be the UnrecoverableLoginErrorViewModel
        XCTAssertTrue(viewModel is UnrecoverableLoginErrorViewModel)
    }
    
    @MainActor
    func test_launchAuthenticationService_authInvalidScope() throws {
        // GIVEN the authentication session returns an invalidScope error
        let viewModel = try given(errorFromStartSession: LoginError(reason: .authorizationInvalidScope), when: { sut in
            // WHEN the LoginCoordinator's launchAuthenticationService method is called
            sut.launchAuthenticationService()
        })

        // THEN the visible view controller's view model should be the UnrecoverableLoginErrorViewModel
        XCTAssertTrue(viewModel is UnrecoverableLoginErrorViewModel)
    }
    
    @MainActor
    func test_launchAuthenticationService_temporarilyUnavailable() throws {
        // GIVEN the authentication session returns an temporarilyUnavailable error
        let viewModel = try given(errorFromStartSession: LoginError(reason: .authorizationTemporarilyUnavailable), when: { sut in
            // WHEN the LoginCoordinator's launchAuthenticationService method is called
            sut.launchAuthenticationService()
        })

        // THEN the visible view controller's view model should be the UnrecoverableLoginErrorViewModel
        XCTAssertTrue(viewModel is UnrecoverableLoginErrorViewModel)
    }
    
    @MainActor
    func test_launchAuthenticationService_tokenInvalidRequest() throws {
        // GIVEN the authentication session returns an invalidRequest error
        let viewModel = try given(errorFromStartSession: LoginError(reason: .tokenInvalidRequest), when: { sut in
            // WHEN the LoginCoordinator's launchAuthenticationService method is called
            sut.launchAuthenticationService()
        })

        // THEN the visible view controller's view model should be the UnrecoverableLoginErrorViewModel
        XCTAssertTrue(viewModel is UnrecoverableLoginErrorViewModel)
    }
    
    @MainActor
    func test_launchAuthenticationService_tokenUnauthorizedClient() throws {
        // GIVEN the authentication session returns an tokenUnauthorizedClient error
        let viewModel = try given(errorFromStartSession: LoginError(reason: .tokenUnauthorizedClient), when: { sut in
            // WHEN the LoginCoordinator's launchAuthenticationService method is called
            sut.launchAuthenticationService()
        })

        // THEN the visible view controller's view model should be the UnrecoverableLoginErrorViewModel
        XCTAssertTrue(viewModel is UnrecoverableLoginErrorViewModel)
    }
    
    @MainActor
    func test_launchAuthenticationService_tokenInvalidScope() throws {
        // GIVEN the authentication session returns an tokenInvalidScope error
        let viewModel = try given(errorFromStartSession: LoginError(reason: .tokenInvalidScope), when: { sut in
            // WHEN the LoginCoordinator's launchAuthenticationService method is called
            sut.launchAuthenticationService()
        })
        // THEN the visible view controller's view model should be the UnrecoverableLoginErrorViewModel
        XCTAssertTrue(viewModel is UnrecoverableLoginErrorViewModel)
    }
    
    @MainActor
    func test_launchAuthenticationService_invalidClient() throws {
        // GIVEN the authentication session returns an tokenInvalidClient error
        let viewModel = try given(errorFromStartSession: LoginError(reason: .tokenInvalidClient), when: { sut in
            // WHEN the LoginCoordinator's launchAuthenticationService method is called
            sut.launchAuthenticationService()
        })

        // THEN the visible view controller's view model should be the UnrecoverableLoginErrorViewModel
        XCTAssertTrue(viewModel is UnrecoverableLoginErrorViewModel)
    }
    
    @MainActor
    func test_launchAuthenticationService_invalidGrant() throws {
        // GIVEN the authentication session returns an tokenInvalidGrant error
        let viewModel = try given(errorFromStartSession: LoginError(reason: .tokenInvalidGrant), when: { sut in
            // WHEN the LoginCoordinator's launchAuthenticationService method is called
            sut.launchAuthenticationService()
        })

        // THEN the visible view controller's view model should be the UnrecoverableLoginErrorViewModel
        XCTAssertTrue(viewModel is UnrecoverableLoginErrorViewModel)
    }
    
    @MainActor
    func test_launchAuthenticationService_unsupportedGrant() throws {
        // GIVEN the authentication session returns an tokenUnsupportedGrantType error
        let viewModel = try given(errorFromStartSession: LoginError(reason: .tokenUnsupportedGrantType), when: { sut in
            // WHEN the LoginCoordinator's launchAuthenticationService method is called
            sut.launchAuthenticationService()
        })

        // THEN the visible view controller's view model should be the UnrecoverableLoginErrorViewModel
        XCTAssertTrue(viewModel is UnrecoverableLoginErrorViewModel)
    }
    
    @MainActor
    func test_launchAuthenticationService_clientError() throws {
        // GIVEN the authentication session returns an tokenClientError error
        let viewModel = try given(errorFromStartSession: LoginError(reason: .tokenClientError), when: { sut in
            // WHEN the LoginCoordinator's launchAuthenticationService method is called
            sut.launchAuthenticationService()
        })

        // THEN the visible view controller's view model should be the UnrecoverableLoginErrorViewModel
        XCTAssertTrue(viewModel is UnrecoverableLoginErrorViewModel)
    }

    @MainActor
    func test_launchAuthenticationService_authServerError() throws {
        let threeTimes = 3
        // GIVEN the authentication session returns a serverError error
        try self.given(errorFromStartSession: LoginError(reason: .authorizationServerError), repeats: threeTimes, when: { sut in
            // WHEN the LoginCoordinator's launchAuthenticationService method is called
            sut.launchAuthenticationService()
        }, then: { attempt, vc in
            if attempt < threeTimes {
                // THEN the visible view controller's view model should be the RecoverableLoginErrorViewModel
                let vc = try XCTUnwrap(vc as? GDSErrorScreen)
                XCTAssertTrue(vc.viewModel is RecoverableLoginErrorViewModel)
            }
            else {
                // 3rd server error should show non-recoverable error screen
                let vc = try XCTUnwrap(vc as? GDSErrorScreen)
                XCTAssertTrue(vc.viewModel is UnrecoverableLoginErrorViewModel)
            }
        })
    }
    
    @MainActor
    func test_launchAuthenticationService_authUnknownError() throws {
        // GIVEN the authentication session returns an authorizationUnknownError error
        let viewModel = try given(errorFromStartSession: LoginError(reason: .authorizationUnknownError), when: { sut in
            // WHEN the LoginCoordinator's launchAuthenticationService method is called
            sut.launchAuthenticationService()
        })

        // THEN the visible view controller's view model should be the RecoverableLoginErrorViewModel
        XCTAssertTrue(viewModel is RecoverableLoginErrorViewModel)
    }
    
    @MainActor
    func test_launchAuthenticationService_tokenUnknownError() throws {
        // GIVEN the authentication session returns an tokenUnknownError error
        let viewModel = try given(errorFromStartSession: LoginError(reason: .tokenUnknownError), when: { sut in
            // WHEN the LoginCoordinator's launchAuthenticationService method is called
            sut.launchAuthenticationService()
        })

        // THEN the visible view controller's view model should be the RecoverableLoginErrorViewModel
        XCTAssertTrue(viewModel is RecoverableLoginErrorViewModel)
    }
    
    @MainActor
    func test_launchAuthenticationService_serverError() throws {
        let threeTimes = 3
        try self.given(errorFromStartSession: LoginError(reason: .generalServerError), repeats: threeTimes, when: { sut in
            sut.launchAuthenticationService()
        }, then: { attempt, vc in
            if attempt < threeTimes {
                let vc = try XCTUnwrap(vc as? GDSErrorScreen)
                XCTAssertTrue(vc.viewModel is RecoverableLoginErrorViewModel)
            }
            else {
                let vc = try XCTUnwrap(vc as? GDSErrorScreen)
                XCTAssertTrue(vc.viewModel is UnrecoverableLoginErrorViewModel)
            }
        })
    }
    
    @MainActor
    func test_launchAuthenticationService_safariError() throws {
        // GIVEN the authentication session returns an safariOpenError error
        let viewModel = try given(errorFromStartSession: LoginError(reason: .safariOpenError), when: { sut in
            // WHEN the LoginCoordinator's launchAuthenticationService method is called
            sut.launchAuthenticationService()
        })

        // THEN the visible view controller's view model should be the RecoverableLoginErrorViewModel
        XCTAssertTrue(viewModel is RecoverableLoginErrorViewModel)
    }
    
    @MainActor
    func test_launchAuthenticationService_jwtFetchError() throws {
        // GIVEN the authentication session returns an unableToFetchJWKs error
        let viewModel = try given(errorFromStartSession: JWTVerifierError.unableToFetchJWKs, when: { sut in
            // WHEN the LoginCoordinator's launchAuthenticationService method is called
            sut.launchAuthenticationService()
        })

        // THEN the visible view controller's view model should be the RecoverableLoginErrorViewModel
        XCTAssertTrue(viewModel is RecoverableLoginErrorViewModel)

    }
    
    @MainActor
    func test_launchAuthenticationService_jwtVerifyError() throws {
        // GIVEN the authentication session returns an invalidJWTFormat error
        let viewModel = try given(errorFromStartSession: JWTVerifierError.invalidJWTFormat, when: { sut in
            // WHEN the LoginCoordinator's launchAuthenticationService method is called
            sut.launchAuthenticationService()
        })

        // THEN the visible view controller's view model should be the RecoverableLoginErrorViewModel
        XCTAssertTrue(viewModel is RecoverableLoginErrorViewModel)
    }
    
    @MainActor
    func test_launchAuthenticationService_appIntegrityNetworkError() throws {
        // GIVEN the authentication session returns an app integrity network error
        let errorFromStartSession = FirebaseAppCheckError(
            .network,
            reason: "test reason"
        )
        let viewModel = try given(errorFromStartSession: errorFromStartSession, when: { sut in
            // WHEN the LoginCoordinator's launchAuthenticationService method is called
            sut.launchAuthenticationService()
        })

        // THEN the visible view controller's view model should be the AppIntegrityErrorViewModel
        XCTAssertTrue(viewModel is AppIntegrityErrorViewModel)
    }
    
    @MainActor
    func test_launchAuthenticationService_appIntegrityUnknownError() throws {
        // GIVEN the authentication session returns an app integrity unknown error
        let errorFromStartSession = FirebaseAppCheckError(
            .unknown,
            reason: "test reason"
        )
        let viewModel = try given(errorFromStartSession: errorFromStartSession, when: { sut in
            // WHEN the LoginCoordinator's launchAuthenticationService method is called
            sut.launchAuthenticationService()
        })

        // THEN the visible view controller's view model should be the AppIntegrityErrorViewModel
        XCTAssertTrue(viewModel is AppIntegrityErrorViewModel)
    }
    
    @MainActor
    func test_launchAuthenticationService_appIntegrityGenericError() throws {
        // GIVEN the authentication session returns an app integrity generic error
        let errorFromStartSession = FirebaseAppCheckError(
            .generic,
            reason: "test reason"
        )
        let viewModel = try given(errorFromStartSession: errorFromStartSession, when: { sut in
            // WHEN the LoginCoordinator's launchAuthenticationService method is called
            sut.launchAuthenticationService()
        })

        // THEN the visible view controller's view model should be the AppIntegrityErrorViewModel
        XCTAssertTrue(viewModel is AppIntegrityErrorViewModel)
    }
    
    @MainActor
    func test_launchAuthenticationService_appIntegrityInvalidTokenError() throws {
        // GIVEN the authentication session returns an app integrity invalid token error
        let errorFromStartSession = ClientAssertionError(
            .invalidToken,
            reason: "test reason"
        )
        let viewModel = try given(errorFromStartSession: errorFromStartSession, when: { sut in
            // WHEN the LoginCoordinator's launchAuthenticationService method is called
            sut.launchAuthenticationService()
        })

        // THEN the visible view controller's view model should be the AppIntegrityErrorViewModel
        XCTAssertTrue(viewModel is AppIntegrityErrorViewModel)
    }
    
    @MainActor
    func test_launchAuthenticationService_appIntegrityServerError() throws {
        // GIVEN the authentication session returns an app integrity server error
        let errorFromStartSession = ClientAssertionError(
            .serverError,
            reason: "test reason"
        )
        let viewModel = try given(errorFromStartSession: errorFromStartSession, when: { sut in
            // WHEN the LoginCoordinator's launchAuthenticationService method is called
            sut.launchAuthenticationService()
        })

        // THEN the visible view controller's view model should be the AppIntegrityErrorViewModel
        XCTAssertTrue(viewModel is AppIntegrityErrorViewModel)
    }
    
    @MainActor
    func test_launchAuthenticationService_appIntegrityCantDecodeClientAssertionError() throws {
        // GIVEN the authentication session returns an cant decode client assertion error
        let errorFromStartSession = ClientAssertionError(
            .cantDecodeClientAssertion,
            reason: "test reason"
        )
        let viewModel = try given(errorFromStartSession: errorFromStartSession, when: { sut in
            // WHEN the LoginCoordinator's launchAuthenticationService method is called
            sut.launchAuthenticationService()
        })

        // THEN the visible view controller's view model should be the AppIntegrityErrorViewModel
        XCTAssertTrue(viewModel is AppIntegrityErrorViewModel)
    }
    
    @MainActor
    func test_launchAuthenticationService_appIntegrityNotSupportedError() throws {
        // GIVEN the authentication session returns an app integrity not supported error
        let errorFromStartSession = FirebaseAppCheckError(
            .notSupported,
            reason: "test reason"
        )
        let viewModel = try given(errorFromStartSession: errorFromStartSession, when: { sut in
            // WHEN the LoginCoordinator's launchAuthenticationService method is called
            sut.launchAuthenticationService()
        })
        
        // THEN the visible view controller's view model should be the AppIntegrityErrorViewModel
        XCTAssertTrue(viewModel is AppIntegrityErrorViewModel)
    }
    
    @MainActor
    func test_launchAuthenticationService_appIntegrityKeychainAccessError() throws {
        // GIVEN the authentication session returns an app integrity keychain access error
        let errorFromStartSession = FirebaseAppCheckError(
            .keychainAccess,
            reason: "test reason"
        )
        let viewModel = try given(errorFromStartSession: errorFromStartSession, when: { sut in
            // WHEN the LoginCoordinator's launchAuthenticationService method is called
            sut.launchAuthenticationService()
        })
        
        // THEN the visible view controller's view model should be the AppIntegrityErrorViewModel
        XCTAssertTrue(viewModel is AppIntegrityErrorViewModel)
    }
    
    @MainActor
    func test_launchAuthenticationService_appIntegrityInvalidConfigurationError() throws {
        // GIVEN the authentication session returns an app integrity invalid configuration error
        let errorFromStartSession = FirebaseAppCheckError(
            .invalidConfiguration,
            reason: "test reason"
        )
        let viewModel = try given(errorFromStartSession: errorFromStartSession, when: { sut in
            // WHEN the LoginCoordinator's launchAuthenticationService method is called
            sut.launchAuthenticationService()
        })
        
        // THEN the visible view controller's view model should be the AppIntegrityErrorViewModel
        XCTAssertTrue(viewModel is AppIntegrityErrorViewModel)
    }
    
    @MainActor
    func test_launchAuthenticationService_appIntegrityInvalidPublicKeyError() throws {
        // GIVEN the authentication session returns an app integrity invalid public key error
        let errorFromStartSession = ClientAssertionError(
            .invalidPublicKey,
            reason: "test reason"
        )
        let viewModel = try given(errorFromStartSession: errorFromStartSession, when: { sut in
            // WHEN the LoginCoordinator's launchAuthenticationService method is called
            sut.launchAuthenticationService()
        })

        // THEN the visible view controller's view model should be the AppIntegrityErrorViewModel
        XCTAssertTrue(viewModel is AppIntegrityErrorViewModel)
    }
    
    @MainActor
    func test_launchAuthenticationService_appIntegrityCantGenerateProofOfPossessionPublicKeyJWK() throws {
        // GIVEN the authentication session returns an app integrity cant generate a proof of possession public key error
        let errorFromStartSession = ProofOfPossessionError(
            .cantGenerateAttestationPublicKeyJWK,
            reason: "test reason"
        )
        let viewModel = try given(errorFromStartSession: errorFromStartSession, when: { sut in
            // WHEN the LoginCoordinator's launchAuthenticationService method is called
            sut.launchAuthenticationService()
        })

        // THEN the visible view controller's view model should be the AppIntegrityErrorViewModel
        XCTAssertTrue(viewModel is AppIntegrityErrorViewModel)
    }
    
    @MainActor
    func test_launchAuthenticationService_appIntegrityCantGenerateProofOfPossessionJWT() throws {
        // GIVEN the authentication session returns an app integrity cant create attestation proof of possession error
        let errorFromStartSession = ProofOfPossessionError(
            .cantGenerateAttestationProofOfPossessionJWT,
            reason: "test reason"
        )
        let viewModel = try given(errorFromStartSession: errorFromStartSession, when: { sut in
            // WHEN the LoginCoordinator's launchAuthenticationService method is called
            sut.launchAuthenticationService()
        })

        // THEN the visible view controller's view model should be the AppIntegrityErrorViewModel
        XCTAssertTrue(viewModel is AppIntegrityErrorViewModel)
    }
    
    @MainActor
    func test_launchAuthenticationService_appIntegrityCantGenerateDemonstratingProofOfPossessionJWT() throws {
        // GIVEN the authentication session returns an app integrity cant generate a DPoP public key error
        let errorFromStartSession = ProofOfPossessionError(
            .cantGenerateDemonstratingProofOfPossessionJWT,
            reason: "test reason"
        )
        let viewModel = try given(errorFromStartSession: errorFromStartSession, when: { sut in
            // WHEN the LoginCoordinator's launchAuthenticationService method is called
            sut.launchAuthenticationService()
        })

        // THEN the visible view controller's view model should be the AppIntegrityErrorViewModel
        XCTAssertTrue(viewModel is AppIntegrityErrorViewModel)
    }
    
    @MainActor
    func test_launchAuthenticationService_generic() throws {
        // GIVEN the authentication session returns a generic error
        let errorFromStartSession = LoginError(reason: .generic(description: ""))
        let viewModel = try given(errorFromStartSession: errorFromStartSession, when: { sut in
            // WHEN the LoginCoordinator's launchAuthenticationService method is called
            sut.launchAuthenticationService()
        })

        // THEN the visible view controller's view model should be the AppIntegrityErrorViewModel
        XCTAssertTrue(viewModel is GenericErrorViewModel)
    }
    
    @MainActor
    func test_launchAuthenticationService_catchAllError() throws {
        // GIVEN the authentication session returns a generic error
        let viewModel = try given(errorFromStartSession: AuthenticationError.generic, when: { sut in
            // WHEN the LoginCoordinator's launchAuthenticationService method is called
            sut.launchAuthenticationService()
        })

        // THEN the visible view controller's view model should be the GenericErrorViewModel
        XCTAssertTrue(viewModel is GenericErrorViewModel)
    }
    
    @MainActor
    func test_handleUniversalLink_catchAllError() throws {
        // GIVEN the authentication session returns a generic error
        let callbackURL = try XCTUnwrap(URL(string: "https://www.test.com"))
        // WHEN the LoginCoordinator's handleUniversalLink method is called
        sut.handleUniversalLink(callbackURL)
        // THEN the visible view controller should be the GDSErrorScreen
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSErrorScreen)
        // THEN the visible view controller's view model should be the GenericErrorViewModel
        XCTAssertTrue(vc.viewModel is GenericErrorViewModel)
    }
    
    // MARK: Coordinator flow
    @MainActor
    func test_promptForAnalyticsPermissions() {
        sut.start()
        // WHEN the promptForAnalyticsPermissions method is called
        sut.loginCoordinatorDidDisplay()
        // THEN the OnboardingCoordinator should be launched
        XCTAssertTrue(sut.childCoordinators[0] is OnboardingCoordinator)
        XCTAssertTrue(sut.root.presentedViewController?.children[0] is ModalInfoViewController)
    }
    
    @MainActor
    func test_skip_promptForAnalyticsPermissions() {
        sut.start()
        // GIVEN the the user has accepted analytics permissions and sessionState = .notLoggedIn
        mockAnalyticsService.analyticsPreferenceStore.hasAcceptedAnalytics = true
        // WHEN the promptForAnalyticsPermissions method is called
        sut.loginCoordinatorDidDisplay()
        // THEN the OnboardingCoordinator will not be launched
        XCTAssertEqual(sut.childCoordinators.count, 0)
    }
    
    @MainActor
    func test_showLogOutConfirmation() {
        // WHEN the LoginCoordinator is started with a userLogOut authState
        sut = LoginCoordinator(appWindow: appWindow,
                               root: navigationController,
                               analyticsService: mockAnalyticsService,
                               sessionManager: mockSessionManager,
                               networkMonitor: mockNetworkMonitor,
                               authService: mockAuthenticationService,
                               sessionState: .userLogOut,
                               serviceState: nil)
        sut.start()
        // WHEN the promptForAnalyticsPermissions method is called
        sut.loginCoordinatorDidDisplay()
        // THEN the log out confirmation screen should be shown
        XCTAssertTrue(sut.root.presentedViewController is GDSInformationViewController)
        XCTAssertTrue((sut.root.presentedViewController as? GDSInformationViewController)?.viewModel is SignOutSuccessfulViewModel)
    }
    
    @MainActor
    func test_showSystemLogOutConfirmation() {
        // WHEN the LoginCoordinator is started with a userLogOut authState
        sut = LoginCoordinator(appWindow: appWindow,
                               root: navigationController,
                               analyticsService: mockAnalyticsService,
                               sessionManager: mockSessionManager,
                               networkMonitor: mockNetworkMonitor,
                               authService: mockAuthenticationService,
                               sessionState: .systemLogOut,
                               serviceState: nil)
        sut.start()
        // WHEN the promptForAnalyticsPermissions method is called
        sut.loginCoordinatorDidDisplay()
        // THEN the log out confirmation screen should be shown
        XCTAssertTrue(sut.root.presentedViewController is GDSErrorScreen)
        XCTAssertTrue((sut.root.presentedViewController as? GDSErrorScreen)?.viewModel is DataDeletedWarningViewModel)
    }
    
    @MainActor
    func test_launchEnrolmentCoordinator() {
        // WHEN the LoginCoordinator's launchEnrolmentCoordinator method is called with the local authentication context
        sut.launchEnrolmentCoordinator()
        // THEN the LoginCoordinator should have an EnrolmentCoordinator as it's only child coordinator
        XCTAssertEqual(sut.childCoordinators.count, 1)
        XCTAssertTrue(sut.childCoordinators[0] is EnrolmentCoordinator)
    }
 }
