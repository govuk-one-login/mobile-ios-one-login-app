import GDSCommon
@testable import OneLogin
import XCTest

@MainActor
final class ProfileCoordinatorTests: XCTestCase {
    var mockAnalyticsService: MockAnalyticsService!
    var urlOpener: URLOpener!
    var sut: ProfileCoordinator!

    override func setUp() {
        super.setUp()
        
        mockAnalyticsService = MockAnalyticsService()
        urlOpener = MockURLOpener()
        sut = ProfileCoordinator(analyticsService: mockAnalyticsService,
                                 urlOpener: urlOpener)
    }

    override func tearDown() {
        mockAnalyticsService = nil
        urlOpener = nil
        sut = nil
        
        super.tearDown()
    }
    
    func test_tabBarItem() throws {
        sut.start()
        let profileTab = UITabBarItem(title: "Profile",
                                      image: UIImage(systemName: "person.crop.circle"),
                                      tag: 2)
        XCTAssertEqual(sut.root.tabBarItem.title, profileTab.title)
        XCTAssertEqual(sut.root.tabBarItem.image, profileTab.image)
        XCTAssertEqual(sut.root.tabBarItem.tag, profileTab.tag)
    }

    func test_updateToken() throws {
        sut.start()
        let vc = try XCTUnwrap(sut.baseVc)
        XCTAssertEqual(try vc.emailLabel.text, "")
        let tokenHolder = TokenHolder()
        tokenHolder.idTokenPayload = MockTokenVerifier.mockPayload
        sut.updateToken(tokenHolder)
        XCTAssertEqual(try vc.emailLabel.text, "You’re signed in as\nmock@email.com")
    }
}
