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
    var mockMainCoordinator: MainCoordinator!
    var sut: AuthenticationCoordinator!
    
    
    override func setUp() {
        super.setUp()
        
        window = .init()
        navigationController = .init()
        mockLoginSession = MockLoginSession(window: window)
        mockAnalyticsService = MockAnalyticsService()
        mockMainCoordinator = MainCoordinator(window: window, root: navigationController)
        sut = AuthenticationCoordinator(root: navigationController,
                                        session: mockLoginSession,
                                        analyticsService: mockAnalyticsService)
    }
    
    override func tearDown() {
        window = nil
        navigationController = nil
        mockLoginSession = nil
        mockAnalyticsService = nil
        mockMainCoordinator = nil
        sut = nil
        
        super.tearDown()
    }
    
    private enum AuthenticationError: Error {
        case catchAll
    }
}

extension AuthenticationCoordinatorTests {
    func test_start_loginSession_configProperties() throws {
        mockMainCoordinator.openChildInline(sut)
        // WHEN the AuthenticationCoordinator is started
        sut.start()
        waitForTruth(self.mockLoginSession.didCallPerformLoginFlow, timeout: 2)
        // THEN the session should have the correct login configuration details
        let sessionConfig = try XCTUnwrap(mockLoginSession.sessionConfiguration)
        XCTAssertEqual(sessionConfig.authorizationEndpoint, AppEnvironment.oneLoginAuthorize)
        XCTAssertEqual(sessionConfig.tokenEndpoint, AppEnvironment.oneLoginToken)
        XCTAssertEqual(sessionConfig.responseType, LoginSessionConfiguration.ResponseType.code)
        XCTAssertEqual(sessionConfig.scopes, [.openid])
        XCTAssertEqual(sessionConfig.clientID, AppEnvironment.oneLoginClientID)
        XCTAssertEqual(sessionConfig.prefersEphemeralWebSession, true)
        XCTAssertEqual(sessionConfig.redirectURI, AppEnvironment.oneLoginRedirect)
        XCTAssertEqual(sessionConfig.vectorsOfTrust, ["Cl.Cm.P0"])
        XCTAssertEqual(sessionConfig.locale, .en)
    }
    
    func test_handleUniversalLink_successful() throws {
        // GIVEN the AuthenticationCoordinator has logged in via start()
        mockMainCoordinator.openChildInline(sut)
        // WHEN the AuthenticationCoordinator calls performLoginFlow on the session and there is no error

        // swiftlint:disable line_length
        let accessToken = "eEd2wTsYiaXEcZrXYoClvP9uZVvsSsJm4fw8haqSLcH8!B!i=U!/viQGDK3aQq/M2aUdwoxUqevzDX!A8NJFWrZ4VfLP/lgMGXdop=l2QtkLtBvP=iYAXCIBjtyP3i-bY5aP3lF4YLnldq02!jQWfxe1TvWesyMi9D1GIDq!X7JAJTMVHUIKH?-C18/-fcgkxHsQZhs/oFsW/56fTPsvdJPteu10nMF1gY0f8AChM6Yl5FAKX=UOdTHIoVJvf9Dt"
        let refreshToken = "JPz2bPDtrU/NJAedvDC8Xk6eMFlf1qZn9MuYXvCDl?xTZlCUFR?oAwUzXlhlr29MiWf1!2NlFYJ5shibOLWPnwCD46LfzZ6fG3ThIgWYZUH/1n-1p/4?UxDuhP/4!Orx-AFFPezxppqSJK9xOsA0GY13sZwNG-61TSV-yzL=OijL3TxTJg7A5q5H7DwZz71CtYiFn1KIsENYQ-7xB8C63tS3epWRF-Tsb7BMWtIUIZC0gODblBz/eAQFCf6lvEjp"
        let idToken = "KdJzZf0ecdXFsSjIYXbh-0A4Hj-X!?JR5dhTqDgkoy6JDP7R5B1mtzD0cgprmflfyi7ihSvRWg1n=RrRgTjj5hG-t1tuN2zmqacHmUpbfKGsZKk6EwfvFxMYh4YINYfqLdFKLgY224uaCRI8F9rDghBoHx5=vMY=L6l3EwG5R8!HND2j2W5JKNwCTp3zKMS4WRYz3Xk?CJEKqa2oFNtFNdoz0rUIH-i/sCgqWkpE2093s0PyMZQ1x49M88mjx=0E"
        // swiftlint:enable line_length
        
        waitForTruth(self.mockLoginSession.didCallPerformLoginFlow, timeout: 2)
        guard let mainCoordinator = sut.parentCoordinator as? MainCoordinator else {
            XCTFail("Should be a MainCoordinator")
            return
        }
        // THEN the tokens are returned
        XCTAssertEqual(mainCoordinator.tokens?.accessToken, accessToken)
        XCTAssertEqual(mainCoordinator.tokens?.refreshToken, refreshToken)
        XCTAssertEqual(mainCoordinator.tokens?.idToken, idToken)
    }
    
    func test_loginError_network() throws {
        mockLoginSession.errorFromPerformLoginFlow = LoginError.network
        mockMainCoordinator.start()
        // GIVEN the AuthenticationCoordinator has logged in via start()
        mockMainCoordinator.openChildInline(sut)
        // WHEN the AuthenticationCoordinator calls performLoginFlow on the session and there is a network error
        waitForTruth(self.navigationController.viewControllers.count == 2, timeout: 2)
        // THEN the 'network' error screen is shown
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSErrorViewController)
        XCTAssertTrue(vc.viewModel is NetworkConnectionErrorViewModel)
        // WHEN the button on the error screen is tapped
        let errorPrimaryButton: UIButton = try XCTUnwrap(vc.view[child: "error-primary-button"])
        errorPrimaryButton.sendActions(for: .touchUpInside)
        waitForTruth(self.navigationController.viewControllers.count == 1, timeout: 2)
        XCTAssertTrue(navigationController.topViewController is IntroViewController)
    }
    
    func test_loginError_non200() throws {
        mockLoginSession.errorFromPerformLoginFlow = LoginError.non200
        mockMainCoordinator.start()
        // GIVEN the AuthenticationCoordinator has logged in via start()
        mockMainCoordinator.openChildInline(sut)
        // WHEN the AuthenticationCoordinator calls performLoginFlow on the session and there is a non200 error
        waitForTruth(self.navigationController.viewControllers.count == 2, timeout: 2)
        // THEN the 'unable to login' error screen is shown
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSErrorViewController)
        XCTAssertTrue(vc.viewModel is UnableToLoginErrorViewModel)
        // WHEN the button on the error screen is tapped
        let errorPrimaryButton: UIButton = try XCTUnwrap(vc.view[child: "error-primary-button"])
        errorPrimaryButton.sendActions(for: .touchUpInside)
        waitForTruth(self.navigationController.viewControllers.count == 1, timeout: 2)
        XCTAssertTrue(navigationController.topViewController is IntroViewController)
    }
    
    func test_loginError_invalidRequest() throws {
        mockLoginSession.errorFromPerformLoginFlow = LoginError.invalidRequest
        mockMainCoordinator.start()
        // GIVEN the AuthenticationCoordinator has logged in via start()
        mockMainCoordinator.openChildInline(sut)
        // WHEN the AuthenticationCoordinator calls performLoginFlow on the session and there is an invalid request error
        waitForTruth(self.navigationController.viewControllers.count == 2, timeout: 2)
        // THEN the 'unable to login' error screen is shown
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSErrorViewController)
        XCTAssertTrue(vc.viewModel is UnableToLoginErrorViewModel)
        // WHEN the button on the error screen is tapped
        let errorPrimaryButton: UIButton = try XCTUnwrap(vc.view[child: "error-primary-button"])
        errorPrimaryButton.sendActions(for: .touchUpInside)
        waitForTruth(self.navigationController.viewControllers.count == 1, timeout: 2)
        XCTAssertTrue(navigationController.topViewController is IntroViewController)
    }
    
    func test_loginError_clientError() throws {
        mockLoginSession.errorFromPerformLoginFlow = LoginError.clientError
        mockMainCoordinator.start()
        // GIVEN the AuthenticationCoordinator has logged in via start()
        mockMainCoordinator.openChildInline(sut)
        // WHEN the AuthenticationCoordinator calls performLoginFlow on the session and there is an client error
        waitForTruth(self.navigationController.viewControllers.count == 2, timeout: 2)
        // THEN the 'unable to login' error screen is shown
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSErrorViewController)
        XCTAssertTrue(vc.viewModel is UnableToLoginErrorViewModel)
        // WHEN the button on the error screen is tapped
        let errorPrimaryButton: UIButton = try XCTUnwrap(vc.view[child: "error-primary-button"])
        errorPrimaryButton.sendActions(for: .touchUpInside)
        waitForTruth(self.navigationController.viewControllers.count == 1, timeout: 2)
        XCTAssertTrue(navigationController.topViewController is IntroViewController)
    }
    
    func test_loginError_generic() throws {
        mockLoginSession.errorFromPerformLoginFlow = LoginError.generic(description: "")
        mockMainCoordinator.start()
        // GIVEN the AuthenticationCoordinator has logged in via start()
        mockMainCoordinator.openChildInline(sut)
        // WHEN the AuthenticationCoordinator calls performLoginFlow on the session and there is an generic error
        waitForTruth(self.navigationController.viewControllers.count == 2, timeout: 2)
        // THEN the 'generic' error screen is shown
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSErrorViewController)
        XCTAssertTrue(vc.viewModel is GenericErrorViewModel)
        // WHEN the button on the error screen is tapped
        let errorPrimaryButton: UIButton = try XCTUnwrap(vc.view[child: "error-primary-button"])
        errorPrimaryButton.sendActions(for: .touchUpInside)
        waitForTruth(self.navigationController.viewControllers.count == 1, timeout: 2)
        XCTAssertTrue(navigationController.topViewController is IntroViewController)
    }
    
    func test_loginError_catchAllError() throws {
        mockLoginSession.errorFromPerformLoginFlow = AuthenticationError.catchAll
        mockMainCoordinator.start()
        // GIVEN the AuthenticationCoordinator has logged in via start()
        mockMainCoordinator.openChildInline(sut)
        // WHEN the AuthenticationCoordinator calls performLoginFlow on the session and there is an unknown error
        waitForTruth(self.navigationController.viewControllers.count == 2, timeout: 2)
        // THEN the 'generic' error screen is shown
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSErrorViewController)
        XCTAssertTrue(vc.viewModel is GenericErrorViewModel)
        // WHEN the button on the error screen is tapped
        let errorPrimaryButton: UIButton = try XCTUnwrap(vc.view[child: "error-primary-button"])
        errorPrimaryButton.sendActions(for: .touchUpInside)
        waitForTruth(self.navigationController.viewControllers.count == 1, timeout: 2)
        XCTAssertTrue(navigationController.topViewController is IntroViewController)
    }
    
    func test_loginError_userCancelled() throws {
        mockLoginSession.errorFromPerformLoginFlow = LoginError.userCancelled
        mockMainCoordinator.start()
        // GIVEN the AuthenticationCoordinator has logged in via start()
        mockMainCoordinator.openChildInline(sut)
        // WHEN the AuthenticationCoordinator calls performLoginFlow on the session and user cancelled the login modal
        waitForTruth(self.mockLoginSession.didCallPerformLoginFlow, timeout: 2)
        // THEN user is returned to the intro screen
        XCTAssertTrue(sut.root.topViewController is IntroViewController)
    }
    
    func test_handleUniversalLink_catchAllError() throws {
        mockLoginSession.errorFromFinalise = AuthenticationError.catchAll
        // WHEN the AuthenticationCoordinator calls finalise on the session and there is an unknown error
        let callbackURL = URL(string: "https://www.test.com")!
        sut.handleUniversalLink(callbackURL)
        // THEN the 'generic' error screen is shown
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSErrorViewController)
        XCTAssertTrue(vc.viewModel is GenericErrorViewModel)
    }
}
