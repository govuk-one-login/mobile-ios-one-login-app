import Authentication
@testable import OneLogin
import XCTest

final class TokensViewControllerTests: XCTestCase {
    var accessToken: String!
    var sut: TokensViewController!
    var didTapDeveloperMenu: Bool!
    
    override func setUp() {
        super.setUp()
        
        didTapDeveloperMenu = false
        let tokensViewModel = TokensViewModel {
            self.didTapDeveloperMenu = true
        }
        sut = TokensViewController(viewModel: tokensViewModel)
        sut.updateToken(accessToken: "testAccessToken")
    }
    
    override func tearDown() {
        sut = nil
        accessToken = nil
        didTapDeveloperMenu = false
        
        super.tearDown()
    }
}

extension TokensViewControllerTests {
    func test_labelContents() throws {
        XCTAssertEqual(try sut.loggedInLabel.attributedText?.string.starts(with: "Logged in"), true)
        XCTAssertEqual(try sut.accessTokenLabel.attributedText?.string, "Access Token: testAccessToken")
    }
    
    func test_developerMenu() throws {
        XCTAssertFalse(didTapDeveloperMenu)
        try sut.developerMenuButton.sendActions(for: .touchUpInside)
        XCTAssertTrue(didTapDeveloperMenu)
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
    
    var developerMenuButton: UIButton {
        get throws {
            try XCTUnwrap(view[child: "developer-menu-button"])
        }
    }
}
