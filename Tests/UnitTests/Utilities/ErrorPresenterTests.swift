#if NOW
@testable import OneLoginNOW
#else
#if NOW
@testable import OneLoginNOW
#else
@testable import OneLogin
#endif

#endif
import XCTest

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
        
        super.tearDown()
    }
}

extension ErrorPresenterTests {
    func test_genericError_callsAction() throws {
        let introView = sut.createGenericError(errorDescription: "error description",
                                               analyticsService: mockAnalyticsService) {
            self.didCallAction = true
        }
        let introButton: UIButton = try XCTUnwrap(introView.view[child: "error-primary-button"])
        introButton.sendActions(for: .touchUpInside)
        XCTAssertTrue(didCallAction)
    }
    
    func test_unableToLoginError_callsAction() throws {
        let introView = sut.createUnableToLoginError(errorDescription: "error description",
                                                     analyticsService: mockAnalyticsService) {
            self.didCallAction = true
        }
        let introButton: UIButton = try XCTUnwrap(introView.view[child: "error-primary-button"])
        introButton.sendActions(for: .touchUpInside)
        XCTAssertTrue(didCallAction)
    }
    
    func test_networkConnectionError_callsAction() throws {
        let introView = sut.createNetworkConnectionError(analyticsService: mockAnalyticsService) {
            self.didCallAction = true
        }
        let introButton: UIButton = try XCTUnwrap(introView.view[child: "error-primary-button"])
        introButton.sendActions(for: .touchUpInside)
        XCTAssertTrue(didCallAction)
    }
    
    func test_signoutError_callsAction() throws {
        let errorView = sut.createSignoutError(errorDescription: "error description",
                                               analyticsService: mockAnalyticsService) {
            self.didCallAction = true
        }
        let exitButton: UIButton = try XCTUnwrap(errorView.view[child: "error-primary-button"])
        exitButton.sendActions(for: .touchUpInside)
        XCTAssertTrue(didCallAction)

    }
}
