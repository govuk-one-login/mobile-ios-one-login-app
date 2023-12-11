@testable import OneLogin
import XCTest

final class GenericErrorViewModelTests: XCTestCase {
    var mockAnalyticsService: MockAnalyticsService!
    var sut: GenericErrorViewModel!
    var didCallButtonAction = false

    override func setUp() {
        super.setUp()

        mockAnalyticsService = MockAnalyticsService()
        sut = GenericErrorViewModel(analyticsService: mockAnalyticsService) {
            self.didCallButtonAction = true
        }
    }

    override func tearDown() {
        mockAnalyticsService = nil
        sut = nil
        didCallButtonAction = false

        super.tearDown()
    }
}

extension GenericErrorViewModelTests {
    func test_labelContents() throws {
        XCTAssertEqual(sut.image, "exclamationmark.circle")
        XCTAssertEqual(sut.title.value, "Something went wrong")
        XCTAssertEqual(sut.body.value, "Try again later")
    }

    func test_buttonAction() throws {
        XCTAssertFalse(didCallButtonAction)
        sut.primaryButtonViewModel.action()
        XCTAssertTrue(didCallButtonAction)
    }
}
