import MobilePlatformServices
import MockNetworking
@testable import Networking
@testable import OneLogin
import SecureStore
import Testing
import UIKit

@MainActor
struct DeveloperMenuViewControllerTests {
    private var devMenuViewModel: DeveloperMenuViewModel!
    private var mockSessionManager: MockSessionManager!
    private var sut: DeveloperMenuViewController!
    private var mockHelloWorldService: MockHelloWorldService!

    private var didCallAccessTokenInvalid: Bool = false

    private var requestFinished = false

    init() {
        AppEnvironment.updateFlags(
            releaseFlags: [:],
            featureFlags: [:]
        )
        MockURLProtocol.clear()
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]

        mockHelloWorldService = MockHelloWorldService()

        devMenuViewModel = DeveloperMenuViewModel()
        mockSessionManager = MockSessionManager()

        sut = DeveloperMenuViewController(viewModel: devMenuViewModel,
                                          sessionManager: mockSessionManager,
                                          helloWorldProvider: mockHelloWorldService)
    }
}

enum MockNetworkClientError: Error {
    case genericError
}

extension DeveloperMenuViewControllerTests {
    @Test
    func test_labelContents_STSEnabled() throws {
        #expect(try sut.happyPathButton.title(for: .normal) == "Hello World Happy")
        #expect(try sut.errorPathButton.title(for: .normal) == "Hello World Error")
        #expect(try sut.unauthorizedPathButton.title(for: .normal) == "Hello World Unauthorized")
    }
    
    @Test
    func test_happyPathButton() async throws {
        // GIVEN I am on the Developer Menu
        // WHEN I tap the happy path button
        try sut.happyPathButton.sendActions(for: .touchUpInside)

        // THEN the hello world API is called
        #expect(await eventually { self.mockHelloWorldService.didRequestHelloWorld })
        // AND the response is displayed
        #expect(try sut.happyPathResultLabel.text == "Success: testData")
    }
    
    @Test
    func test_errorPathButton() async throws {
        // GIVEN I have an active user session
        // WHEN I request a Service Token using an invalid scope
        try sut.errorPathButton.sendActions(for: .touchUpInside)

        // THEN the hello world API is called
        #expect(await eventually { self.mockHelloWorldService.didRequestHelloWorldWithWrongScope })

        // AND an error message is displayed:
        #expect(try sut.errorPathResultLabel.text == "Error code: 404\nEndpoint: hello-world")
    }

    @Test
    func test_unauthorizedPathButton() async throws {
        // GIVEN I have an active user session
        // WHEN I call an invalid endpoint
        try sut.unauthorizedPathButton.sendActions(for: .touchUpInside)
        // THEN an error message is displayed
        #expect(await eventually { self.mockHelloWorldService.didRequestHelloWorldAtWrongEndpoint })
        #expect(try sut.unauthorizedPathResultLabel.text == "Error")
    }
    
    @Test
    func test_deletePersistentSessionIDButton() throws {
        // GIVEN I have an active session
        try mockSessionManager.setupSession()
        // WHEN I tap the delete persistent session ID button
        try sut.deletePersistentSessionIDButton.sendActions(for: .touchUpInside)
        // THEN the button becomes purple
        #expect(try sut.deletePersistentSessionIDButton.backgroundColor == .gdsBrightPurple)
    }
    
    @Test
    func test_expireAccessTokenButton() throws {
        // GIVEN I have an active session
        try mockSessionManager.setupSession()
        // WHEN I tap the expire access token button
        try sut.expireAccessTokenButton.sendActions(for: .touchUpInside)
        // THEN the button becomes purple
        #expect(try sut.expireAccessTokenButton.backgroundColor == .gdsBrightPurple)
    }
    
    @Test
    func test_expireRefreshTokenButton() throws {
        // GIVEN I have an active session
        try mockSessionManager.setupSession()
        // WHEN I tap the expire refresh token button
        try sut.expireRefreshTokenButton.sendActions(for: .touchUpInside)
        // THEN the button becomes purple
        #expect(try sut.expireRefreshTokenButton.backgroundColor == .gdsBrightPurple)
    }
}

extension DeveloperMenuViewController {
    var happyPathButton: UIButton {
        get throws {
            try #require(view[child: "sts-happy-path-button"])
        }
    }
    
    var happyPathResultLabel: UILabel {
        get throws {
            try #require(view[child: "sts-happy-path-result"])
        }
    }
    
    var errorPathButton: UIButton {
        get throws {
            try #require(view[child: "sts-error-path-button"])
        }
    }
    
    var errorPathResultLabel: UILabel {
        get throws {
            try #require(view[child: "sts-error-path-result"])
        }
    }
    
    var unauthorizedPathButton: UIButton {
        get throws {
            try #require(view[child: "sts-unauthorized-path-button"])
        }
    }
    
    var unauthorizedPathResultLabel: UILabel {
        get throws {
            try #require(view[child: "sts-unauthorized-path-result"])
        }
    }
    
    var deletePersistentSessionIDButton: UIButton {
        get throws {
            try #require(view[child: "sts-delete-persistent-session-id-path-button"])
        }
    }
    
    var expireAccessTokenButton: UIButton {
        get throws {
            try #require(view[child: "sts-expire-access-token-button"])
        }
    }
    
    var expireRefreshTokenButton: UIButton {
        get throws {
            try #require(view[child: "sts-expire-refresh-token-button"])
        }
    }
}
