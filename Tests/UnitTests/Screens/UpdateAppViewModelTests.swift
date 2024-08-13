import GDSAnalytics
@testable import OneLogin
import XCTest

@MainActor
final class UpdateAppViewModelTests: XCTestCase {
    var mockAnalyticsService: MockAnalyticsService!
    var sut: UpdateAppViewModel!
    var didCallPrimaryButtonAction = false

    override func setUp() {
        super.setUp()

        mockAnalyticsService = MockAnalyticsService()
        sut = UpdateAppViewModel(analyticsService: mockAnalyticsService) {
            self.didCallPrimaryButtonAction = true
        }
    }

    override func tearDown() {
        mockAnalyticsService = nil
        sut = nil
        didCallPrimaryButtonAction = false

        super.tearDown()
    }
}

extension UpdateAppViewModelTests {
    func test_label_contents() throws {
        XCTAssertEqual(sut.title.stringKey, "app_updateApp_Title")
        XCTAssertEqual(sut.body?.stringKey, "app_updateApp_body1")
        XCTAssertEqual(sut.footnote?.stringKey, "app_updateApp_body2")
        XCTAssertEqual(sut.image, "exclamationmark.arrow.circlepath")
    }
}