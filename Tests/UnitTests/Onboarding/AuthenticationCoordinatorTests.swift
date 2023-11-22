import Authentication
@testable import OneLogin
import XCTest

@MainActor
final class AuthenticationCoordinatorTests: XCTestCase {
    var window: UIWindow!
    var navigationController: UINavigationController!
    var mockLoginSession: MockLoginSession!
    var sut: AuthenticationCoordinator!
    
    override func setUp() {
        super.setUp()
        
        window = .init()
        navigationController = .init()
        mockLoginSession = MockLoginSession(window: window)
        sut = AuthenticationCoordinator(root: navigationController, session: mockLoginSession)
    }
    
    override func tearDown() {
        navigationController = nil
        mockLoginSession = nil
        sut = nil
        
        super.tearDown()
    }
}

extension AuthenticationCoordinatorTests {
    func test_start_authenticationSessionConfigProperties() throws {
        // WHEN the AuthenticationCoordinator is started
        sut.start()
        XCTAssertTrue(mockLoginSession.sessionConfiguration != nil)
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

    func test_start_authenticationSessionPresent() throws {
        // WHEN the AuthenticationCoordinator is started
        sut.start()
        // THEN the session should call present() with the configuration
        let sessionConfig = try XCTUnwrap(mockLoginSession.sessionConfiguration)
        mockLoginSession.present(configuration: sessionConfig)
        XCTAssertTrue(mockLoginSession.didCallPresent)
    }

    func test_handleUniversalLink_finaliseCalled() throws {
        // WHEN AuthenticationCoordinator has logged in via start()
        sut.start()
        let accessToken = "eEd2wTsYiaXEcZrXYoClvP9uZVvsSsJm4fw8haqSLcH8!B!i=U!/viQGDK3aQq/M2aUdwoxUqevzDX!A8NJFWrZ4VfLP/lgMGXdop=l2QtkLtBvP=iYAXCIBjtyP3i-bY5aP3lF4YLnldq02!jQWfxe1TvWesyMi9D1GIDq!X7JAJTMVHUIKH?-C18/-fcgkxHsQZhs/oFsW/56fTPsvdJPteu10nMF1gY0f8AChM6Yl5FAKX=UOdTHIoVJvf9Dt"
        let refreshToken = "JPz2bPDtrU/NJAedvDC8Xk6eMFlf1qZn9MuYXvCDl?xTZlCUFR?oAwUzXlhlr29MiWf1!2NlFYJ5shibOLWPnwCD46LfzZ6fG3ThIgWYZUH/1n-1p/4?UxDuhP/4!Orx-AFFPezxppqSJK9xOsA0GY13sZwNG-61TSV-yzL=OijL3TxTJg7A5q5H7DwZz71CtYiFn1KIsENYQ-7xB8C63tS3epWRF-Tsb7BMWtIUIZC0gODblBz/eAQFCf6lvEjp"
        let idToken = "KdJzZf0ecdXFsSjIYXbh-0A4Hj-X!?JR5dhTqDgkoy6JDP7R5B1mtzD0cgprmflfyi7ihSvRWg1n=RrRgTjj5hG-t1tuN2zmqacHmUpbfKGsZKk6EwfvFxMYh4YINYfqLdFKLgY224uaCRI8F9rDghBoHx5=vMY=L6l3EwG5R8!HND2j2W5JKNwCTp3zKMS4WRYz3Xk?CJEKqa2oFNtFNdoz0rUIH-i/sCgqWkpE2093s0PyMZQ1x49M88mjx=0E"
        // THEN AuthenticationCoordinator calls finalise and returns the with tokens
        let tokens = try mockLoginSession.finalise(callback: URL(string: "https://www.test.com")!)
        XCTAssertTrue(mockLoginSession.didCallFinalise)
        XCTAssertEqual(tokens.accessToken, accessToken)
        XCTAssertEqual(tokens.refreshToken, refreshToken)
        XCTAssertEqual(tokens.idToken, idToken)
    }
}
