import GDSCommon
@testable import OneLogin
import XCTest

@MainActor
final class ProfileCoordinatorTests: XCTestCase {

    var sut: ProfileCoordinator!
    var window: UIWindow!
    var urlOpener: URLOpener!

    override func setUp() {
        super.setUp()
        urlOpener = MockURLOpener()
        sut = ProfileCoordinator(urlOpener: urlOpener)
        window = .init()
    }

    override func tearDown() {
        sut = nil
        urlOpener = nil
        window = nil
        super.tearDown()
    }

    func test_updateToken() throws {
        sut.start()
        let vc = try XCTUnwrap(sut.baseVc)
        XCTAssertEqual(try vc.emailLabel.text, nil)
        sut.updateToken(accessToken: "testAccessToken")
        XCTAssertEqual(try vc.emailLabel.text, "You’re signed in as\nsarahelizabeth_1991@gmail.com")
    }
}
