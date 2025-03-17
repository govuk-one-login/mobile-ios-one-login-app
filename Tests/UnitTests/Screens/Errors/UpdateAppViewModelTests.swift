import GDSAnalytics
@testable import OneLogin
import XCTest

@MainActor
final class UpdateAppViewModelTests: XCTestCase {
    var mockAnalyticsService: MockAnalyticsService!
    var urlOpener: MockURLOpener!
    var sut: UpdateAppViewModel!

    override func setUp() {
        super.setUp()

        mockAnalyticsService = MockAnalyticsService()
        urlOpener = .init()
        sut = UpdateAppViewModel(analyticsService: mockAnalyticsService,
                                 urlOpener: urlOpener)
    }

    override func tearDown() {
        mockAnalyticsService = nil
        urlOpener = nil
        sut = nil

        super.tearDown()
    }
}

extension UpdateAppViewModelTests {
    func test_page() {
        XCTAssertEqual(sut.imageWeight, .regular)
        XCTAssertEqual(sut.image, "exclamationmark.arrow.circlepath")
        XCTAssertEqual(sut.title.stringKey, "app_updateAppTitle")
        XCTAssertEqual(sut.body?.stringKey, "app_updateAppBody")
        XCTAssertNil(sut.rightBarButtonTitle)
        XCTAssertTrue(sut.backButtonIsHidden)
    }

    func test_button() {
        XCTAssertEqual(sut.primaryButtonViewModel.title.stringKey, "app_updateAppButton")
        XCTAssertEqual(sut.primaryButtonViewModel.accessibilityHint?.stringKey, "app_externalApp")
        XCTAssertFalse(urlOpener.didOpenURL)
        sut.primaryButtonViewModel.action()
        XCTAssertTrue(urlOpener.didOpenURL)
    }
}
