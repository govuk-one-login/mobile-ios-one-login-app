import MockNetworking
@testable import Networking
@testable import OneLogin
import SecureStore
import XCTest

@MainActor
final class DeveloperMenuViewControllerTests: XCTestCase {
    var mockAnalyticsService: MockAnalyticsService!
    var devMenuViewModel: DeveloperMenuViewModel!
    var mockAuthenicatedSecureStore: SecureStorable!
    var mockOpenSecureStore: SecureStorable!
    var mockDefaultsStore: MockDefaultsStore!
    var mockUserStore: MockUserStore!
    var networkClient: NetworkClient!
    var homeCoordinator: HomeCoordinator!
    var sut: DeveloperMenuViewController!
    
    var requestFinished = false
    
    override func setUp() {
        super.setUp()
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        UserDefaults.standard.set(true, forKey: FeatureFlags.enableCallingSTS.rawValue)
        
        mockAnalyticsService = MockAnalyticsService()
        devMenuViewModel = DeveloperMenuViewModel()
        mockAuthenicatedSecureStore = MockSecureStoreService()
        mockOpenSecureStore = MockSecureStoreService()
        mockDefaultsStore = MockDefaultsStore()
        mockUserStore = MockUserStore(authenticatedStore: mockAuthenicatedSecureStore,
                                      openStore: mockOpenSecureStore,
                                      defaultsStore: mockDefaultsStore)
        networkClient = NetworkClient(configuration: configuration,
                                      authenticationProvider: MockAuthenticationProvider())
        homeCoordinator = HomeCoordinator(analyticsService: mockAnalyticsService,
                                          userStore: mockUserStore)
        sut = DeveloperMenuViewController(parentCoordinator: homeCoordinator,
                                          viewModel: devMenuViewModel,
                                          userStore: mockUserStore,
                                          networkClient: networkClient)
    }
    
    override func tearDown() {
        UserDefaults.standard.set(false, forKey: FeatureFlags.enableCallingSTS.rawValue)
        
        mockAnalyticsService = nil
        devMenuViewModel = nil
        mockAuthenicatedSecureStore = nil
        mockOpenSecureStore = nil
        mockDefaultsStore = nil
        mockUserStore = nil
        networkClient = nil
        homeCoordinator = nil
        sut = nil
        
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
        UserDefaults.standard.set(false, forKey: FeatureFlags.enableCallingSTS.rawValue)
        XCTAssertTrue(try sut.happyPathButton.isHidden)
        XCTAssertTrue(try sut.errorPathButton.isHidden)
        XCTAssertTrue(try sut.unauthorizedPathButton.isHidden)
        UserDefaults.standard.set(true, forKey: FeatureFlags.enableCallingSTS.rawValue)
    }
    
    func test_happyPathButton() throws {
        mockDefaultsStore.set(Date() + 60, forKey: .accessTokenExpiry)
        
        let exchangeData = Data("""
            {
                "access_token": "testAccessToken",
                "token_type": "testTokenType",
                "expires_in": 123456789
            }
        """.utf8)
        
        var networkCallsMade = 0
        MockURLProtocol.handler = { [unowned self] in
            defer {
                networkCallsMade += 1
                if networkCallsMade > 1 {
                    requestFinished = true
                }
            }
            switch networkCallsMade {
            case 0:
                return (exchangeData, HTTPURLResponse(statusCode: 200))
            default:
                return (Data("testData".utf8), HTTPURLResponse(statusCode: 200))
            }
        }
        
        try sut.happyPathButton.sendActions(for: .touchUpInside)
        waitForTruth(self.requestFinished, timeout: 20)
        XCTAssertEqual(try sut.happyPathResultLabel.text, "Success: testData")
    }
    
    func test_happyPathButton_invalidAccessTokenActionCalled() throws {
        mockDefaultsStore.removeObject(forKey: .accessTokenExpiry)
        TokenHolder.shared.tokenResponse = nil
        try sut.happyPathButton.sendActions(for: .touchUpInside)
    }
    
    func test_errorPathButton() throws {
        mockDefaultsStore.set(Date() + 60, forKey: .accessTokenExpiry)

        MockURLProtocol.handler = { [unowned self] in
            defer {
                requestFinished = true
            }
            return (Data(), HTTPURLResponse(statusCode: 404))
        }
        
        try sut.errorPathButton.sendActions(for: .touchUpInside)
        waitForTruth(self.requestFinished, timeout: 20)
        XCTAssertEqual(try sut.errorPathResultLabel.text, "Error code: 404\nEndpoint: token")
    }
    
    func test_errorPathButton_invalidAccessTokenActionCalled() throws {
        mockDefaultsStore.removeObject(forKey: .accessTokenExpiry)
        TokenHolder.shared.tokenResponse = nil
        try sut.errorPathButton.sendActions(for: .touchUpInside)
    }

    func test_unauthorizedPathButton() throws {
        mockDefaultsStore.set(Date() + 60, forKey: .accessTokenExpiry)

        MockURLProtocol.handler = { [unowned self] in
            defer {
                requestFinished = true
            }
            throw MockNetworkClientError.genericError
        }
        
        try sut.unauthorizedPathButton.sendActions(for: .touchUpInside)
        waitForTruth(self.requestFinished, timeout: 20)
        XCTAssertEqual(try sut.unauthorizedPathResultLabel.text, "Error")
    }
    
    func test_unauthorized_invalidAccessTokenActionCalled() throws {
        mockDefaultsStore.removeObject(forKey: .accessTokenExpiry)
        TokenHolder.shared.tokenResponse = nil
        try sut.unauthorizedPathButton.sendActions(for: .touchUpInside)
    }
    
    func test_deletePersistentSessionIDButton() throws {
        try mockOpenSecureStore.saveItem(item: "123456789", itemName: .persistentSessionID)
        try sut.deletePersistentSessionIDButton.sendActions(for: .touchUpInside)
        XCTAssertFalse(mockOpenSecureStore.checkItemExists(itemName: .persistentSessionID))
        XCTAssertTrue(try sut.deletePersistentSessionIDButton.backgroundColor == .gdsBrightPurple)
    }
    
    func test_expireAccessTokenButton() throws {
        mockDefaultsStore.set("123456789", forKey: .accessTokenExpiry)
        try sut.expireAccessTokenButton.sendActions(for: .touchUpInside)
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
