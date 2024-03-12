import Authentication
@testable import OneLogin
import XCTest

final class TokensViewControllerTests: XCTestCase {
    var tokens: TokenResponse!
    var sut: TokensViewController!
    
    override func setUp() {
        super.setUp()
        
        tokens = try? MockTokenResponse().getJSONData()
        sut = TokensViewController(tokens: tokens)
    }
    
    override func tearDown() {
        sut = nil
        tokens = nil
        
        super.tearDown()
    }
    
    // swiftlint:disable line_length
    let accessToken = "eEd2wTsYiaXEcZrXYoClvP9uZVvsSsJm4fw8haqSLcH8!B!i=U!/viQGDK3aQq/M2aUdwoxUqevzDX!A8NJFWrZ4VfLP/lgMGXdop=l2QtkLtBvP=iYAXCIBjtyP3i-bY5aP3lF4YLnldq02!jQWfxe1TvWesyMi9D1GIDq!X7JAJTMVHUIKH?-C18/-fcgkxHsQZhs/oFsW/56fTPsvdJPteu10nMF1gY0f8AChM6Yl5FAKX=UOdTHIoVJvf9Dt"
    let refreshToken = "JPz2bPDtrU/NJAedvDC8Xk6eMFlf1qZn9MuYXvCDl?xTZlCUFR?oAwUzXlhlr29MiWf1!2NlFYJ5shibOLWPnwCD46LfzZ6fG3ThIgWYZUH/1n-1p/4?UxDuhP/4!Orx-AFFPezxppqSJK9xOsA0GY13sZwNG-61TSV-yzL=OijL3TxTJg7A5q5H7DwZz71CtYiFn1KIsENYQ-7xB8C63tS3epWRF-Tsb7BMWtIUIZC0gODblBz/eAQFCf6lvEjp"
    let idToken = "KdJzZf0ecdXFsSjIYXbh-0A4Hj-X!?JR5dhTqDgkoy6JDP7R5B1mtzD0cgprmflfyi7ihSvRWg1n=RrRgTjj5hG-t1tuN2zmqacHmUpbfKGsZKk6EwfvFxMYh4YINYfqLdFKLgY224uaCRI8F9rDghBoHx5=vMY=L6l3EwG5R8!HND2j2W5JKNwCTp3zKMS4WRYz3Xk?CJEKqa2oFNtFNdoz0rUIH-i/sCgqWkpE2093s0PyMZQ1x49M88mjx=0E"
    // swiftlint:enable line_length
}

extension TokensViewControllerTests {
    func test_labelContents() throws {
        XCTAssertEqual(try sut.loggedInLabel.attributedText?.string.starts(with: "Logged in"), true)
        XCTAssertEqual(try sut.accessTokenLabel.attributedText?.string, "Access Token: \(accessToken)")
        XCTAssertEqual(try sut.idTokenLabel.attributedText?.string, "ID Token: \(idToken)")
        XCTAssertEqual(try sut.refreshTokenLabel.attributedText?.string, "Refresh Token: \(refreshToken)")
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
    
    var idTokenLabel: UILabel {
        get throws {
            try XCTUnwrap(view[child: "id-token"])
        }
    }
    
    var refreshTokenLabel: UILabel {
        get throws {
            try XCTUnwrap(view[child: "refresh-token"])
        }
    }
}
