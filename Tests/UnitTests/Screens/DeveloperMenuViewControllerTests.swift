import MockNetworking
@testable import Networking
@testable import OneLogin
import XCTest

final class DeveloperMenuViewControllerTests: XCTestCase {
    var networkClient: NetworkClient!
    var devMenuViewModel: DeveloperMenuViewModel!
    var sut: DeveloperMenuViewController!
    
    var requestFinished = false
    
    override func setUp() {
        super.setUp()
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        
        networkClient = NetworkClient(configuration: configuration,
                                      authenticationProvider: MockAuthenticationProvider())
        devMenuViewModel = DeveloperMenuViewModel()
        sut = DeveloperMenuViewController(viewModel: devMenuViewModel,
                                          networkClient: networkClient)
    }
    
    override func tearDown() {
        networkClient = nil
        devMenuViewModel = nil
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
        UserDefaults.standard.set(true, forKey: "EnableCallingSTS")
        XCTAssertEqual(try sut.happyPathButton.title(for: .normal), "Hello World Happy")
        XCTAssertEqual(try sut.errorPathButton.title(for: .normal), "Hello World Error")
        XCTAssertEqual(try sut.unauthorizedPathButton.title(for: .normal), "Hello World Unauthorized")
        UserDefaults.standard.set(false, forKey: "EnableCallingSTS")
    }
    
    func test_labelContents_STSDisabled() throws {
        XCTAssertTrue(try sut.happyPathButton.isHidden)
        XCTAssertTrue(try sut.errorPathButton.isHidden)
        XCTAssertTrue(try sut.unauthorizedPathButton.isHidden)
    }
    
    func test_happyPathButton() throws {
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
        
        UserDefaults.standard.set(true, forKey: "EnableCallingSTS")
        try sut.happyPathButton.sendActions(for: .touchUpInside)
        waitForTruth(self.requestFinished, timeout: 20)
        XCTAssertEqual(try sut.happyPathResultLabel.text, "Success: testData")
        UserDefaults.standard.set(false, forKey: "EnableCallingSTS")
    }
    
    func test_unhappyPathButton() throws {
        MockURLProtocol.handler = { [unowned self] in
            defer {
                requestFinished = true
            }
            return (Data(), HTTPURLResponse(statusCode: 404))
        }
        
        UserDefaults.standard.set(true, forKey: "EnableCallingSTS")
        try sut.errorPathButton.sendActions(for: .touchUpInside)
        waitForTruth(self.requestFinished, timeout: 20)
        XCTAssertEqual(try sut.errorPathResultLabel.text, "Error code: 404\nEndpoint: token")
        UserDefaults.standard.set(false, forKey: "EnableCallingSTS")
    }

    func test_unsuccessfulPathButton() throws {
        MockURLProtocol.handler = { [unowned self] in
            defer {
                requestFinished = true
            }
            throw MockNetworkClientError.genericError
        }
        
        UserDefaults.standard.set(true, forKey: "EnableCallingSTS")
        try sut.errorPathButton.sendActions(for: .touchUpInside)
        waitForTruth(self.requestFinished, timeout: 20)
        XCTAssertEqual(try sut.errorPathResultLabel.text, "Error")
        UserDefaults.standard.set(false, forKey: "EnableCallingSTS")
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
