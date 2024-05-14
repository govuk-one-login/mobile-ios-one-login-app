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

    func test_updateToken() throws {
        sut.start()
        let vc = try XCTUnwrap(sut.baseVc)
        XCTAssertEqual(try vc.emailLabel.text, nil)
        sut.updateToken(accessToken: "testAccessToken")
        XCTAssertEqual(try vc.emailLabel.text, "You’re signed in as\nsarahelizabeth_1991@gmail.com")
    }
}
