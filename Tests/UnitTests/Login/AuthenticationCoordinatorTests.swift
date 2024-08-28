import Authentication
import GDSAnalytics
import GDSCommon
@testable import OneLogin
import XCTest

final class AuthenticationCoordinatorTests: XCTestCase {
    var window: UIWindow!
    var navigationController: UINavigationController!
    var mockAnalyticsService: MockAnalyticsService!
    var mockSessionManager: MockSessionManager!
    var mockLoginSession: MockLoginSession!
    var mockTokenVerifier: MockTokenVerifier!
    var sut: AuthenticationCoordinator!

    @MainActor
    override func setUp() {
        super.setUp()

        window = .init()
        navigationController = .init()
        mockAnalyticsService = MockAnalyticsService()
        mockSessionManager = MockSessionManager()
        mockLoginSession = MockLoginSession(window: window)
        sut = AuthenticationCoordinator(window: window,
                                        root: navigationController,
                                        analyticsService: mockAnalyticsService,
                                        sessionManager: mockSessionManager,
                                        session: mockLoginSession)

        AppEnvironment.updateReleaseFlags([
            FeatureFlags.enableCallingSTS.rawValue: true
        ])
    }
    
    override func tearDown() {
        window = nil
        navigationController = nil
        mockAnalyticsService = nil
        mockSessionManager = nil
        mockLoginSession = nil
        sut = nil

        AppEnvironment.updateReleaseFlags([:])

        super.tearDown()
    }
    
    private enum AuthenticationError: Error {
        case generic
    }
}

extension AuthenticationCoordinatorTests {
    @MainActor
    func test_start_loginSession_successful() throws {
        // GIVEN there is an existing (expired) user session
        // WHEN the AuthenticationCoordinator is started
        // and the AuthenticationCoordinator calls performLoginFlow on the session
        // and there is no error
        sut.start()
        waitForTruth(self.mockSessionManager.didCallStartSession, timeout: 20)
    }
    
    @MainActor
    func test_start_loginError_network() throws {
        mockSessionManager.errorFromStartSession = LoginError.network
        sut.start()
        // WHEN the AuthenticationCoordinator is started
        // WHEN the AuthenticationCoordinator calls performLoginFlow on the session
        // and there is a network error
        waitForTruth(self.navigationController.viewControllers.count == 1, timeout: 20)
        // THEN the 'network' error screen is shown
        XCTAssertTrue(sut.root.topViewController is GDSErrorViewController)
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSErrorViewController)
        XCTAssertTrue(vc.viewModel is NetworkConnectionErrorViewModel)
        // THEN the loginError should be a netwok error
        XCTAssertTrue(sut.authError as? LoginError == .network)
    }
    
    @MainActor
    func test_start_loginError_non200() throws {
        mockSessionManager.errorFromStartSession = LoginError.non200
        sut.start()
        // GIVEN the AuthenticationCoordinator has logged in via start()
        // WHEN the AuthenticationCoordinator calls performLoginFlow on the session
        // and there is a non200 error
        waitForTruth(self.navigationController.viewControllers.count == 1, timeout: 20)
        // THEN the 'unable to login' error screen is shown
        XCTAssertTrue(sut.root.topViewController is GDSErrorViewController)
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSErrorViewController)
        XCTAssertTrue(vc.viewModel is UnableToLoginErrorViewModel)
        // THEN the loginError should be a non200 error
        XCTAssertTrue(sut.authError as? LoginError == .non200)
    }
    
    @MainActor
    func test_loginError_invalidRequest() throws {
        mockSessionManager.errorFromStartSession = LoginError.invalidRequest
        sut.start()
        // GIVEN the AuthenticationCoordinator has logged in via start()
        // WHEN the AuthenticationCoordinator calls performLoginFlow on the session
        // and there is a non200 error
        waitForTruth(self.navigationController.viewControllers.count == 1, timeout: 20)
        // THEN the 'unable to login' error screen is shown
        XCTAssertTrue(sut.root.topViewController is GDSErrorViewController)
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSErrorViewController)
        XCTAssertTrue(vc.viewModel is UnableToLoginErrorViewModel)
        // THEN the loginError should be an invalidRequest error
        XCTAssertTrue(sut.authError as? LoginError == .invalidRequest)
    }
    
    @MainActor
    func test_loginError_clientError() throws {
        mockSessionManager.errorFromStartSession = LoginError.clientError
        sut.start()
        // GIVEN the AuthenticationCoordinator has logged in via start()
        // WHEN the AuthenticationCoordinator calls performLoginFlow on the session
        // and there is a non200 error
        waitForTruth(self.navigationController.viewControllers.count == 1, timeout: 20)
        // THEN the 'unable to login' error screen is shown
        XCTAssertTrue(sut.root.topViewController is GDSErrorViewController)
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSErrorViewController)
        XCTAssertTrue(vc.viewModel is UnableToLoginErrorViewModel)
        // THEN the loginError should be a clientError error
        XCTAssertTrue(sut.authError as? LoginError == .clientError)

    }
    
    @MainActor
    func test_loginError_serverError() throws {
        mockSessionManager.errorFromStartSession = LoginError.serverError
        sut.start()
        // GIVEN the AuthenticationCoordinator has logged in via start()
        // WHEN the AuthenticationCoordinator calls performLoginFlow on the session
        // and there is a server error
        waitForTruth(self.navigationController.viewControllers.count == 1, timeout: 20)
        // THEN the 'unable to login' error screen is shown
        XCTAssertTrue(sut.root.topViewController is GDSErrorViewController)
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSErrorViewController)
        XCTAssertTrue(vc.viewModel is UnableToLoginErrorViewModel)
        // THEN the loginError should be a serverError error
        XCTAssertTrue(sut.authError as? LoginError == .serverError)
    }
    
    @MainActor
    func test_loginError_generic() throws {
        mockSessionManager.errorFromStartSession = LoginError.generic(description: "")
        sut.start()
        // GIVEN the AuthenticationCoordinator has logged in via start()
        // WHEN the AuthenticationCoordinator calls performLoginFlow on the session
        // and there is a generic error
        waitForTruth(self.navigationController.viewControllers.count == 1, timeout: 20)
        // THEN the 'generic' error screen is shown
        XCTAssertTrue(sut.root.topViewController is GDSErrorViewController)
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSErrorViewController)
        XCTAssertTrue(vc.viewModel is GenericErrorViewModel)
        // THEN the loginError should be a generic error
        XCTAssertTrue(sut.authError as? LoginError == .generic(description: ""))
    }
    
    @MainActor
    func test_loginError_catchAllError() throws {
        mockSessionManager.errorFromStartSession = AuthenticationError.generic
        sut.start()
        // GIVEN the AuthenticationCoordinator has logged in via start()
        // WHEN the AuthenticationCoordinator calls performLoginFlow on the session
        // and there is an unknown error
        waitForTruth(self.navigationController.viewControllers.count == 1, timeout: 20)
        // THEN the 'generic' error screen is shown
        XCTAssertTrue(sut.root.topViewController is GDSErrorViewController)
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSErrorViewController)
        XCTAssertTrue(vc.viewModel is GenericErrorViewModel)
        // THEN the loginError should be an unknown generic error
        XCTAssertTrue(sut.authError as? AuthenticationError == .generic)
    }
    
    @MainActor
    func test_loginError_userCancelled() throws {
        mockSessionManager.errorFromStartSession = LoginError.userCancelled
        sut.start()
        // GIVEN the AuthenticationCoordinator has logged in via start()
        // WHEN the AuthenticationCoordinator calls performLoginFlow on the session
        // and user cancelled the login modal
        waitForTruth(self.mockSessionManager.didCallStartSession, timeout: 20)
        // THEN user is returned to the intro screen
        // THEN the loginError should be a userCancelled error
        sut.authError = LoginError.userCancelled
        // THEN a trackButtonEvent is logged with text value "back"
        let userCancelledEvent = ButtonEvent(textKey: "back")
        XCTAssertEqual(mockAnalyticsService.eventsLogged, [userCancelledEvent.name.name])
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged["text"], userCancelledEvent.parameters["text"])
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged["type"], userCancelledEvent.parameters["type"])
    }
    
    @MainActor
    func test_loginError_jwtFetchError() throws {
        mockSessionManager.errorFromStartSession = JWTVerifierError.unableToFetchJWKs
        sut.start()
        // GIVEN the AuthenticationCoordinator has logged in via start()
        // WHEN the AuthenticationCoordinator calls performLoginFlow on the session
        // and the subsequent call to the JWKS service fails
        waitForTruth(self.mockSessionManager.didCallStartSession, timeout: 20)
        // THEN the login error screen is shown
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSErrorViewController)
        XCTAssertTrue(vc.viewModel is UnableToLoginErrorViewModel)
        // THEN the loginError should be an unableToFetchJWKs error
        XCTAssertTrue(sut.authError as? JWTVerifierError == .unableToFetchJWKs)
    }
    
    @MainActor
    func test_loginError_jwtVerifyError() throws {
        mockSessionManager.errorFromStartSession = JWTVerifierError.invalidJWTFormat
        sut.start()
        // GIVEN the AuthenticationCoordinator has logged in via start()
        // WHEN the AuthenticationCoordinator calls performLoginFlow on the session
        // and the subsequent call to the JWKS service fails
        waitForTruth(self.mockSessionManager.didCallStartSession, timeout: 20)
        // THEN the login error screen is shown
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSErrorViewController)
        XCTAssertTrue(vc.viewModel is UnableToLoginErrorViewModel)
        // THEN the loginError should be an unableToFetchJWKs error
        XCTAssertTrue(sut.authError as? JWTVerifierError == .invalidJWTFormat)
    }
    
    @MainActor
    func test_handleUniversalLink_catchAllError() throws {
        mockLoginSession.errorFromFinalise = AuthenticationError.generic
        // WHEN the AuthenticationCoordinator calls finalise on the session
        // and there is an unknown error
        let callbackURL = URL(string: "https://www.test.com")!
        sut.handleUniversalLink(callbackURL)
        waitForTruth(self.navigationController.viewControllers.count == 2, timeout: 20)
        // THEN the loading screen is on the navigation stack
        XCTAssertTrue(navigationController.viewControllers.first is GDSLoadingViewController)
        // THEN the 'generic' error screen is top of the navigation stack
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSErrorViewController)
        XCTAssertTrue(vc.viewModel is GenericErrorViewModel)
        // THEN the loginError should be an unknown generic error
        XCTAssertTrue(sut.authError as? AuthenticationError == .generic)
    }
    
    @MainActor
    func test_returnFromErrorScreen() throws {
        mockSessionManager.errorFromStartSession = AuthenticationError.generic
        sut.start()
        // GIVEN the AuthenticationCoordinator has logged in via start()
        // WHEN the AuthenticationCoordinator calls performLoginFlow on the session
        waitForTruth(self.navigationController.viewControllers.count == 1, timeout: 20)
        // THEN an error screen is shown
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSErrorViewController)
        // WHEN the primary button of the error screen is selected
        let errorButton: UIButton = try XCTUnwrap(vc.view[child: "error-primary-button"])
        errorButton.sendActions(for: .touchUpInside)
        // THEN the added view controller should be removed
        XCTAssertEqual(navigationController.viewControllers.count, 0)
    }
}
