@testable import OneLogin
import XCTest

final class DeveloperMenuViewControllerTests: XCTestCase {
    var mockNetworkClient: MockNetworkClient!
    var sut: DeveloperMenuViewController!
    
    override func setUp() {
        super.setUp()
        
        mockNetworkClient = MockNetworkClient()
        let devMenuViewModel = DeveloperMenuViewModel()
        sut = DeveloperMenuViewController(viewModel: devMenuViewModel,
                                          networkClient: mockNetworkClient)
    }
    
    override func tearDown() {
        mockNetworkClient = nil
        sut = nil
        
        super.tearDown()
    }
    
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
        UserDefaults.standard.set(true, forKey: "EnableCallingSTS")
        mockNetworkClient.authorizedData = "testData".data(using: .utf8)
        try sut.happyPathButton.sendActions(for: .touchUpInside)
        waitForTruth(self.mockNetworkClient.requestFinished == true, timeout: 3)
        XCTAssertEqual(try sut.happyPathResultLabel.text, "Success: testData")
        UserDefaults.standard.set(false, forKey: "EnableCallingSTS")
    }
    
    func test_unhappyPathButton() throws {
        UserDefaults.standard.set(true, forKey: "EnableCallingSTS")
        try sut.errorPathButton.sendActions(for: .touchUpInside)
        waitForTruth(self.mockNetworkClient.requestFinished == true, timeout: 3)
        XCTAssertEqual(try sut.errorPathResultLabel.text, "Error")
        UserDefaults.standard.set(false, forKey: "EnableCallingSTS")
    }
    
    func test_unsuccessfulPathButton() throws {
        UserDefaults.standard.set(true, forKey: "EnableCallingSTS")
        try sut.unauthorizedPathButton.sendActions(for: .touchUpInside)
        waitForTruth(self.mockNetworkClient.requestFinished == true, timeout: 3)
        XCTAssertEqual(try sut.unauthorizedPathResultLabel.text, "Error")
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
