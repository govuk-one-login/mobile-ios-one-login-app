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

/*
 TESTS
 - AuthenticationCoordinator start populates TokenHolder.TokenResponse with Tokens
 - AuthenticationCoordinator start throws error which is stored in loginError and error screen is displayed
 - AuthenticationCoordinator handleUniversalLink throws error which is stored in loginError and error screen is displayed
 */

extension AuthenticationCoordinatorTests {
    func test_start_loginSession_successful() throws {
        // WHEN the AuthenticationCoordinator is started
        // WHEN the AuthenticationCoordinator calls performLoginFlow on the session
        // and there is no error
        sut.start()

        // swiftlint:disable line_length
        let accessToken = "eEd2wTsYiaXEcZrXYoClvP9uZVvsSsJm4fw8haqSLcH8!B!i=U!/viQGDK3aQq/M2aUdwoxUqevzDX!A8NJFWrZ4VfLP/lgMGXdop=l2QtkLtBvP=iYAXCIBjtyP3i-bY5aP3lF4YLnldq02!jQWfxe1TvWesyMi9D1GIDq!X7JAJTMVHUIKH?-C18/-fcgkxHsQZhs/oFsW/56fTPsvdJPteu10nMF1gY0f8AChM6Yl5FAKX=UOdTHIoVJvf9Dt"
        let refreshToken = "JPz2bPDtrU/NJAedvDC8Xk6eMFlf1qZn9MuYXvCDl?xTZlCUFR?oAwUzXlhlr29MiWf1!2NlFYJ5shibOLWPnwCD46LfzZ6fG3ThIgWYZUH/1n-1p/4?UxDuhP/4!Orx-AFFPezxppqSJK9xOsA0GY13sZwNG-61TSV-yzL=OijL3TxTJg7A5q5H7DwZz71CtYiFn1KIsENYQ-7xB8C63tS3epWRF-Tsb7BMWtIUIZC0gODblBz/eAQFCf6lvEjp"
        let idToken = "KdJzZf0ecdXFsSjIYXbh-0A4Hj-X!?JR5dhTqDgkoy6JDP7R5B1mtzD0cgprmflfyi7ihSvRWg1n=RrRgTjj5hG-t1tuN2zmqacHmUpbfKGsZKk6EwfvFxMYh4YINYfqLdFKLgY224uaCRI8F9rDghBoHx5=vMY=L6l3EwG5R8!HND2j2W5JKNwCTp3zKMS4WRYz3Xk?CJEKqa2oFNtFNdoz0rUIH-i/sCgqWkpE2093s0PyMZQ1x49M88mjx=0E"
        // swiftlint:enable line_length

        waitForTruth(self.mockLoginSession.didCallPerformLoginFlow, timeout: 20)
        // THEN the tokens are returned
        XCTAssertEqual(tokenHolder.tokenResponse?.accessToken, accessToken)
        XCTAssertEqual(tokenHolder.tokenResponse?.refreshToken, refreshToken)
        XCTAssertEqual(tokenHolder.tokenResponse?.idToken, idToken)
    }

    func test_start_loginError_network() throws {
        mockLoginSession.errorFromPerformLoginFlow = LoginError.network
        sut.start()
        // WHEN the AuthenticationCoordinator is started
        // WHEN the AuthenticationCoordinator calls performLoginFlow on the session
        // and there is a network error
        waitForTruth(self.navigationController.viewControllers.count == 1, timeout: 20)
        XCTAssertTrue(sut.root.topViewController is GDSErrorViewController)
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSErrorViewController)
        XCTAssertTrue(vc.viewModel is NetworkConnectionErrorViewModel)
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
        sut.loginError = AuthenticationError.generic
    }
}
