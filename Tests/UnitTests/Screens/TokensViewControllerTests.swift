import Authentication
@testable import OneLogin
import XCTest

final class TokensViewControllerTests: XCTestCase {
    var accessToken: String!
    var sut: TokensViewController!
    
    override func setUp() {
        super.setUp()
        
        accessToken = "testAccessToken"
        sut = TokensViewController(accessToken: accessToken)
    }
    
    override func tearDown() {
        sut = nil
        accessToken = nil
        
        super.tearDown()
    }
}

extension TokensViewControllerTests {
    func test_labelContents() throws {
        XCTAssertEqual(try sut.loggedInLabel.attributedText?.string.starts(with: "Logged in"), true)
        XCTAssertEqual(try sut.accessTokenLabel.attributedText?.string, "Access Token: testAccessToken")
    }
}

extension TokensViewController {
    var loggedInLabel: UILabel {
        get throws {
            try XCTUnwrap(view[child: "logged-in-title"])
        }
    }
    
    var accessTokenLabel: UILabel {
        get throws {
            try XCTUnwrap(view[child: "access-token"])
        }
    }
}
