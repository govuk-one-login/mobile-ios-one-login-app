import MockNetworking
@testable import Networking
@testable import OneLogin
import SecureStore
import XCTest

final class DeveloperMenuViewControllerTests: XCTestCase {
    var mockAnalyticsService: MockAnalyticsService!
    var devMenuViewModel: DeveloperMenuViewModel!
    var mockSessionManager: MockSessionManager!
    var networkClient: NetworkClient!
    var homeCoordinator: HomeCoordinator!
    var sut: DeveloperMenuViewController!
    
    var requestFinished = false
    
    @MainActor
    override func setUp() {
        super.setUp()
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]

        networkClient = NetworkClient(configuration: configuration)
        networkClient.authorizationProvider = MockAuthenticationProvider()

        AppEnvironment.updateReleaseFlags([
            FeatureFlags.enableCallingSTS.rawValue: true
        ])

        mockAnalyticsService = MockAnalyticsService()
        devMenuViewModel = DeveloperMenuViewModel()
        mockSessionManager = MockSessionManager()
        homeCoordinator = HomeCoordinator(analyticsService: mockAnalyticsService,
                                          networkClient: networkClient,
                                          sessionManager: mockSessionManager)
        sut = DeveloperMenuViewController(parentCoordinator: homeCoordinator,
                                          viewModel: devMenuViewModel,
                                          sessionManager: mockSessionManager,
                                          networkClient: networkClient)
    }
    
    override func tearDown() {
        AppEnvironment.updateReleaseFlags([:])

        mockAnalyticsService = nil
        devMenuViewModel = nil
        mockSessionManager = nil
        networkClient = nil
        homeCoordinator = nil
        sut = nil
        MockURLProtocol.clear()
        
        requestFinished = false
        
        super.tearDown()
    }
}

enum MockNetworkClientError: Error {
    case genericError
}

extension DeveloperMenuViewControllerTests {
    func test_labelContents_STSEnabled() throws {
        XCTAssertEqual(try sut.happyPathButton.title(for: .normal), "Hello World Happy")
        XCTAssertEqual(try sut.errorPathButton.title(for: .normal), "Hello World Error")
        XCTAssertEqual(try sut.unauthorizedPathButton.title(for: .normal), "Hello World Unauthorized")
    }
    
    func test_labelContents_STSDisabled() throws {
        AppEnvironment.updateReleaseFlags([
            FeatureFlags.enableCallingSTS.rawValue: false
        ])

        XCTAssertTrue(try sut.happyPathButton.isHidden)
        XCTAssertTrue(try sut.errorPathButton.isHidden)
        XCTAssertTrue(try sut.unauthorizedPathButton.isHidden)

        AppEnvironment.updateReleaseFlags([
            FeatureFlags.enableCallingSTS.rawValue: true
        ])
    }
    
    func test_happyPathButton() throws {
        // GIVEN I am on the Developer Menu
        // AND I have a user session
        try mockSessionManager.setupSession()

        MockURLProtocol.handler = {[unowned self] in
            defer {
                requestFinished = true
            }
            return (Data("testData".utf8), HTTPURLResponse(statusCode: 200))
        }
        
        // WHEN I tap the happy path button
        try sut.happyPathButton.sendActions(for: .touchUpInside)

        // THEN the service token is requested from STS
        // AND the hello world API is called
        waitForTruth(self.requestFinished, timeout: 10)
        XCTAssertEqual(try sut.happyPathResultLabel.text, "Success: testData")
    }
    
    func test_happyPathButton_invalidAccessTokenActionCalled() throws {
        let exp = XCTNSNotificationExpectation(name: Notification.Name(.startReauth),
                                               object: nil,
                                               notificationCenter: NotificationCenter.default)
        // GIVEN I have no active session
        MockURLProtocol.handler = {
            (Data(), HTTPURLResponse(statusCode: 400))
        }
        // AND the happy path button is tapped
        try sut.happyPathButton.sendActions(for: .touchUpInside)
        // THEN a notification is sent requesting reauthentication
        wait(for: [exp], timeout: 20)
    }
    
    func test_errorPathButton() throws {
        // GIVEN I have an active user session
        try mockSessionManager.setupSession()

        MockURLProtocol.handler = { [unowned self] in
            defer {
                requestFinished = true
            }
            return (Data(), HTTPURLResponse(statusCode: 404))
        }
        
        // WHEN I request a Service Token using an invalid scope
        try sut.errorPathButton.sendActions(for: .touchUpInside)
        waitForTruth(self.requestFinished, timeout: 10)

        // THEN an error message is displayed:
        XCTAssertEqual(try sut.errorPathResultLabel.text, "Error code: 404\nEndpoint: hello-world")
    }
    
    func test_errorPathButton_invalidAccessTokenActionCalled() throws {
        let exp = XCTNSNotificationExpectation(name: Notification.Name(.startReauth),
                                               object: nil,
                                               notificationCenter: NotificationCenter.default)
        // GIVEN I have no active session
        MockURLProtocol.handler = {
            (Data(), HTTPURLResponse(statusCode: 400))
        }
        // AND the error path button is tapped
        try sut.errorPathButton.sendActions(for: .touchUpInside)
        // THEN a notification is sent requesting reauthentication
        wait(for: [exp], timeout: 20)
    }

    func test_unauthorizedPathButton() throws {
        // GIVEN I have an active user session
        try mockSessionManager.setupSession()

        MockURLProtocol.handler = { [unowned self] in
            defer {
                requestFinished = true
            }
            throw MockNetworkClientError.genericError
        }
        
        // WHEN I call an invalid endpoint
        try sut.unauthorizedPathButton.sendActions(for: .touchUpInside)

        // THEN an error message is displayed
        waitForTruth(self.requestFinished, timeout: 20)
        XCTAssertEqual(try sut.unauthorizedPathResultLabel.text, "Error")
    }
    
    func test_unauthorized_invalidAccessTokenActionCalled() throws {
        let exp = XCTNSNotificationExpectation(name: Notification.Name(.startReauth),
                                               object: nil,
                                               notificationCenter: NotificationCenter.default)
        // GIVEN I have no active session
        MockURLProtocol.handler = {
            (Data(), HTTPURLResponse(statusCode: 400))
        }
        // AND the happy path bitton is tapped
        try sut.unauthorizedPathButton.sendActions(for: .touchUpInside)
        // THEN a notification is sent requesting reauthentication
        wait(for: [exp], timeout: 20)
    }
    
    func test_deletePersistentSessionIDButton() throws {
        // GIVEN I have an active session
        try mockSessionManager.setupSession()
        // WHEN I tap the delete persistent session ID button
        try sut.deletePersistentSessionIDButton.sendActions(for: .touchUpInside)
        // THEN the button becomes purple
        XCTAssertTrue(try sut.deletePersistentSessionIDButton.backgroundColor == .gdsBrightPurple)
    }
    
    func test_expireAccessTokenButton() throws {
        // GIVEN I have an active session
        try mockSessionManager.setupSession()
        // WHEN I tap the expire access token button
        try sut.expireAccessTokenButton.sendActions(for: .touchUpInside)
        // THEN the button becomes purple
        XCTAssertTrue(try sut.expireAccessTokenButton.backgroundColor == .gdsBrightPurple)
    }
}

extension DeveloperMenuViewController {
    var happyPathButton: UIButton {
        get throws {
            try XCTUnwrap(view[child: "sts-happy-path-button"])
        }
    }
    
    var happyPathResultLabel: UILabel {
        get throws {
            try XCTUnwrap(view[child: "sts-happy-path-result"])
        }
    }
    
    var errorPathButton: UIButton {
        get throws {
            try XCTUnwrap(view[child: "sts-error-path-button"])
        }
    }
    
    var errorPathResultLabel: UILabel {
        get throws {
            try XCTUnwrap(view[child: "sts-error-path-result"])
        }
    }
    
    var unauthorizedPathButton: UIButton {
        get throws {
            try XCTUnwrap(view[child: "sts-unauthorized-path-button"])
        }
    }
    
    var unauthorizedPathResultLabel: UILabel {
        get throws {
            try XCTUnwrap(view[child: "sts-unauthorized-path-result"])
        }
    }
    
    var deletePersistentSessionIDButton: UIButton {
        get throws {
            try XCTUnwrap(view[child: "sts-delete-persistent-session-id-path-button"])
        }
    }
    
    var expireAccessTokenButton: UIButton {
        get throws {
            try XCTUnwrap(view[child: "sts-expire-access-token-button"])
        }
    }
}
