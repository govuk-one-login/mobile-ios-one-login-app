@testable import OneLogin
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
    func test_genericErrorCallsAction() throws {
        let introView = sut.createGenericError(analyticsService: mockAnalyticsService) {
            self.didCallAction = true
        }
        let introButton: UIButton = try XCTUnwrap(introView.view[child: "error-primary-button"])
        introButton.sendActions(for: .touchUpInside)
        XCTAssertTrue(didCallAction)
    }
    
    func test_unableToLoginErrorCallsAction() throws {
        let introView = sut.createUnableToLoginError(analyticsService: mockAnalyticsService) {
            self.didCallAction = true
        }
        let introButton: UIButton = try XCTUnwrap(introView.view[child: "error-primary-button"])
        introButton.sendActions(for: .touchUpInside)
        XCTAssertTrue(didCallAction)
    }
    
    func test_networkConnectionErrorCallsAction() throws {
        let introView = sut.createNetworkConnectionError(analyticsService: mockAnalyticsService){
            self.didCallAction = true
        }
        let introButton: UIButton = try XCTUnwrap(introView.view[child: "error-primary-button"])
        introButton.sendActions(for: .touchUpInside)
        XCTAssertTrue(didCallAction)
    }
}
