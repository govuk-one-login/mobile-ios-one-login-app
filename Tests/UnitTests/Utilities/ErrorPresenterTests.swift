@testable import OneLogin
import XCTest

@MainActor
final class ErrorPresenterTests: XCTestCase {
    var mockAnalyticsService: MockAnalyticsService!
    var sut: ErrorPresenter.Type!
    var didCallAction = false
    
    override func setUp() {
        super.setUp()
        
        mockAnalyticsService = MockAnalyticsService()
        sut = ErrorPresenter.self
    }
    
    override func tearDown() {
        mockAnalyticsService = nil
        sut = nil
        didCallAction = false
        
        super.tearDown()
    }
}

extension ErrorPresenterTests {
    func test_signOutError_callsAction() throws {
        let errorView = sut.createSignOutError(errorDescription: "error description",
                                               analyticsService: mockAnalyticsService) {
            self.didCallAction = true
        }
        let exitButton: UIButton = try XCTUnwrap(errorView.view[child: "error-primary-button"])
        exitButton.sendActions(for: .touchUpInside)
        XCTAssertTrue(didCallAction)
    }
}
