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
        sut = UpdateAppViewModel(urlOpener: urlOpener,
                                 analyticsService: mockAnalyticsService) { }
    }

    override func tearDown() {
        mockAnalyticsService = nil
        urlOpener = nil
        sut = nil

        super.tearDown()
    }
}

extension UpdateAppViewModelTests {
    func test_label_contents() throws {
        XCTAssertEqual(sut.title.stringKey, "app_updateAppTitle")
        XCTAssertEqual(sut.body?.stringKey, "app_updateAppBody")
        XCTAssertEqual(sut.primaryButtonViewModel.title, "app_updateAppButton")
        XCTAssertEqual(sut.imageWeight, .regular)
        XCTAssertEqual(sut.image, "exclamationmark.arrow.circlepath")
    }

    func test_didCallButtonAction() throws {
        XCTAssertNil(sut.primaryButtonViewModel.icon)
        XCTAssertFalse(urlOpener.didOpenURL)
        sut.primaryButtonViewModel.action()
        XCTAssertTrue(urlOpener.didOpenURL)
    }
}
