import GDSAnalytics
@testable import OneLogin
import XCTest

final class BiometricEnrollViewModelTests: XCTestCase {
    var mockAnalyticsService: MockAnalyticsService!
    var sut: BiometricEnrollViewModel!
    var didCallPrimaryButtonAction = false
    var didCallSecondaryButtonAction = false

    override func setUp() {
        super.setUp()

        mockAnalyticsService = MockAnalyticsService()
        sut = BiometricEnrollViewModel(analyticsService: mockAnalyticsService, image: "faceid", title: "Test") {
            self.didCallPrimaryButtonAction = true
        } secondaryButtonAction: {
            self.didCallSecondaryButtonAction = true
        }
    }

    override func tearDown() {
        mockAnalyticsService = nil
        sut = nil
        didCallPrimaryButtonAction = false
        didCallSecondaryButtonAction = false

        super.tearDown()
    }
}

extension BiometricEnrollViewModelTests {
    func test_labelContents() throws {
        XCTAssertEqual(sut.image, "faceid")
    }
}
