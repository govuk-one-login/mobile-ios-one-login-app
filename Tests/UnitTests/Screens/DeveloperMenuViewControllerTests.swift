import MockNetworking
@testable import Networking
@testable import OneLogin
import SecureStore
import XCTest

final class DeveloperMenuViewControllerTests: XCTestCase {
    var devMenuViewModel: DeveloperMenuViewModel!
    var mockAuthenicatedSecureStore: SecureStorable!
    var mockOpenSecureStore: SecureStorable!
    var mockDefaultsStore: MockDefaultsStore!
    var mockUserStore: MockUserStore!
    var networkClient: NetworkClient!
    var sut: DeveloperMenuViewController!
    
    var invalidAccessTokenActionCalled = false
    var requestFinished = false
    
    override func setUp() {
        super.setUp()
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        UserDefaults.standard.set(true, forKey: "EnableCallingSTS")
        
        devMenuViewModel = DeveloperMenuViewModel { self.invalidAccessTokenActionCalled = true }
        mockAuthenicatedSecureStore = MockSecureStoreService()
        mockOpenSecureStore = MockSecureStoreService()
        mockDefaultsStore = MockDefaultsStore()
        mockUserStore = MockUserStore(authenticatedStore: mockAuthenicatedSecureStore,
                                      openStore: mockOpenSecureStore,
                                      defaultsStore: mockDefaultsStore)
        networkClient = NetworkClient(configuration: configuration,
                                      authenticationProvider: MockAuthenticationProvider())
        sut = DeveloperMenuViewController(viewModel: devMenuViewModel,
                                          userStore: mockUserStore,
                                          networkClient: networkClient)
    }
    
    override func tearDown() {
        UserDefaults.standard.set(false, forKey: "EnableCallingSTS")

        devMenuViewModel = nil
        mockAuthenicatedSecureStore = nil
        mockOpenSecureStore = nil
        mockDefaultsStore = nil
        mockUserStore = nil
        networkClient = nil
        sut = nil
        
        invalidAccessTokenActionCalled = false
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
        UserDefaults.standard.set(false, forKey: "EnableCallingSTS")
        XCTAssertTrue(try sut.happyPathButton.isHidden)
        XCTAssertTrue(try sut.errorPathButton.isHidden)
        XCTAssertTrue(try sut.unauthorizedPathButton.isHidden)
        UserDefaults.standard.set(true, forKey: "EnableCallingSTS")
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
        try sut.happyPathButton.sendActions(for: .touchUpInside)
        XCTAssertTrue(invalidAccessTokenActionCalled)
    }
    
    func test_unhappyPathButton() throws {
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
    
    func test_unhappyPathButton_invalidAccessTokenActionCalled() throws {
        try sut.errorPathButton.sendActions(for: .touchUpInside)
        XCTAssertTrue(invalidAccessTokenActionCalled)
    }

    func test_unsuccessfulPathButton() throws {
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
    
    func test_unsuccessfulPathButton_invalidAccessTokenActionCalled() throws {
        try sut.unauthorizedPathButton.sendActions(for: .touchUpInside)
        XCTAssertTrue(invalidAccessTokenActionCalled)
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
}
