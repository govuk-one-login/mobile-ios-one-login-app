import MobilePlatformServices
import MockNetworking
@testable import Networking
@testable import OneLogin
import SecureStore
import XCTest

final class DeveloperMenuViewControllerTests: XCTestCase {
    private var devMenuViewModel: DeveloperMenuViewModel!
    private var mockSessionManager: MockSessionManager!
    private var sut: DeveloperMenuViewController!
    private var mockHelloWorldService: MockHelloWorldService!

    private var didCallAccessTokenInvalid: Bool = false

    private var requestFinished = false

    @MainActor
    override func setUp() {
        super.setUp()
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]

        mockHelloWorldService = MockHelloWorldService()

        devMenuViewModel = DeveloperMenuViewModel()
        mockSessionManager = MockSessionManager()

        sut = DeveloperMenuViewController(viewModel: devMenuViewModel,
                                          sessionManager: mockSessionManager,
                                          helloWorldProvider: mockHelloWorldService)
    }
    
    override func tearDown() {
        AppEnvironment.updateFlags(
            releaseFlags: [:],
            featureFlags: [:]
        )
        devMenuViewModel = nil
        mockSessionManager = nil
        sut = nil

        mockHelloWorldService = nil

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
    
    func test_happyPathButton() throws {
        // GIVEN I am on the Developer Menu
        // WHEN I tap the happy path button
        try sut.happyPathButton.sendActions(for: .touchUpInside)

        // THEN the hello world API is called
        waitForTruth(self.mockHelloWorldService.didRequestHelloWorld, timeout: 10)
        // AND the response is displayed
        XCTAssertEqual(try sut.happyPathResultLabel.text, "Success: testData")
    }
    
    func test_errorPathButton() throws {
        // GIVEN I have an active user session
        // WHEN I request a Service Token using an invalid scope
        try sut.errorPathButton.sendActions(for: .touchUpInside)

        // THEN the hello world API is called
        waitForTruth(self.mockHelloWorldService.didRequestHelloWorldWithWrongScope, timeout: 10)

        // AND an error message is displayed:
        XCTAssertEqual(try sut.errorPathResultLabel.text, "Error code: 404\nEndpoint: hello-world")
    }

    func test_unauthorizedPathButton() throws {
        // GIVEN I have an active user session
        // WHEN I call an invalid endpoint
        try sut.unauthorizedPathButton.sendActions(for: .touchUpInside)
        // THEN an error message is displayed
        waitForTruth(self.mockHelloWorldService.didRequestHelloWorldAtWrongEndpoint, timeout: 10)
        XCTAssertEqual(try sut.unauthorizedPathResultLabel.text, "Error")
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
