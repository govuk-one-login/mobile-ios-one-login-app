import Authentication
import GDSCommon
@testable import OneLogin
import XCTest

@MainActor
final class AuthenticationCoordinatorTests: XCTestCase {
    var window: UIWindow!
    var navigationController: UINavigationController!
    var mockLoginSession: MockLoginSession!
    var mockAnalyticsService: MockAnalyticsService!
    var tokenHolder: TokenHolder!
    var sut: AuthenticationCoordinator!
    
    
    override func setUp() {
        super.setUp()
        
        window = .init()
        navigationController = .init()
        mockLoginSession = MockLoginSession(window: window)
        mockAnalyticsService = MockAnalyticsService()
        tokenHolder = TokenHolder()
        sut = AuthenticationCoordinator(root: navigationController,
                                        session: mockLoginSession,
                                        analyticsService: mockAnalyticsService,
                                        tokenHolder: tokenHolder)
    }

    override func tearDown() {
        window = nil
        navigationController = nil
        mockLoginSession = nil
        mockAnalyticsService = nil
        tokenHolder = nil
        sut = nil

        super.tearDown()
    }

    private enum AuthenticationError: Error {
        case generic
    }
}

extension AuthenticationCoordinatorTests {
    func test_start_loginSession_successful() throws {
        // WHEN the AuthenticationCoordinator is started
        // WHEN the AuthenticationCoordinator calls performLoginFlow on the session
        // and there is no error
        sut.start()
        waitForTruth(self.mockLoginSession.didCallPerformLoginFlow, timeout: 20)
        // THEN the tokens are returned
        XCTAssertEqual(tokenHolder.tokenResponse?.accessToken, "accessTokenResponse")
        XCTAssertEqual(tokenHolder.tokenResponse?.refreshToken, "refreshTokenResponse")
        XCTAssertEqual(tokenHolder.tokenResponse?.idToken, "idTokenResponse")
    }

    func test_start_loginError_network() throws {
        mockLoginSession.errorFromPerformLoginFlow = LoginError.network
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
        sut.loginError = LoginError.network
    }

    func test_start_loginError_non200() throws {
        mockLoginSession.errorFromPerformLoginFlow = LoginError.non200
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
        sut.loginError = LoginError.non200
    }

    func test_loginError_invalidRequest() throws {
        mockLoginSession.errorFromPerformLoginFlow = LoginError.invalidRequest
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
        sut.loginError = LoginError.invalidRequest
    }

    func test_loginError_clientError() throws {
        mockLoginSession.errorFromPerformLoginFlow = LoginError.clientError
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
        sut.loginError = LoginError.clientError
    }

    func test_loginError_generic() throws {
        mockLoginSession.errorFromPerformLoginFlow = LoginError.generic(description: "")
        sut.start()
        // GIVEN the AuthenticationCoordinator has logged in via start()
        // WHEN the AuthenticationCoordinator calls performLoginFlow on the session
        // and there is a non200 error
        waitForTruth(self.navigationController.viewControllers.count == 1, timeout: 20)
        // THEN the 'unable to login' error screen is shown
        XCTAssertTrue(sut.root.topViewController is GDSErrorViewController)
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSErrorViewController)
        XCTAssertTrue(vc.viewModel is GenericErrorViewModel)
        // THEN the loginError should be a generic error
        sut.loginError = LoginError.generic(description: "")
    }

    func test_loginError_catchAllError() throws {
        mockLoginSession.errorFromPerformLoginFlow = AuthenticationError.generic
        sut.start()
        // GIVEN the AuthenticationCoordinator has logged in via start()
        // WHEN the AuthenticationCoordinator calls performLoginFlow on the session
        // and there is a non200 error
        waitForTruth(self.navigationController.viewControllers.count == 1, timeout: 20)
        // THEN the 'unable to login' error screen is shown
        XCTAssertTrue(sut.root.topViewController is GDSErrorViewController)
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSErrorViewController)
        XCTAssertTrue(vc.viewModel is GenericErrorViewModel)
        // THEN the loginError should be an unknown generic error
        sut.loginError = AuthenticationError.generic
    }

    func test_loginError_userCancelled() throws {
        mockLoginSession.errorFromPerformLoginFlow = LoginError.userCancelled
        sut.start()
        // GIVEN the AuthenticationCoordinator has logged in via start()
        // WHEN the AuthenticationCoordinator calls performLoginFlow on the session
        // and user cancelled the login modal
        waitForTruth(self.mockLoginSession.didCallPerformLoginFlow, timeout: 20)
        // THEN user is returned to the intro screen
        // THEN the loginError should be a userCancelled error
        sut.loginError = LoginError.userCancelled
    }

    func test_handleUniversalLink_catchAllError() throws {
        mockLoginSession.errorFromFinalise = AuthenticationError.generic
        // WHEN the AuthenticationCoordinator calls finalise on the session
        // and there is an unknown error
        let callbackURL = URL(string: "https://www.test.com")!
        sut.handleUniversalLink(callbackURL)
        // THEN the 'generic' error screen is shown
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSErrorViewController)
        XCTAssertTrue(vc.viewModel is GenericErrorViewModel)
        // THEN the loginError should be an unknown generic error
        sut.loginError = AuthenticationError.generic
    }
}
