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
        didCallAction = false
        
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
    
    func test_signOutError_callsAction() throws {
        let errorView = sut.createSignOutError(errorDescription: "error description",
                                               analyticsService: mockAnalyticsService) {
            self.didCallAction = true
        }
        let exitButton: UIButton = try XCTUnwrap(errorView.view[child: "error-primary-button"])
        exitButton.sendActions(for: .touchUpInside)
        XCTAssertTrue(didCallAction)
    }
    
    func test_signOutWarning_callsAction() throws {
        let errorView = sut.createSignOutWarning(analyticsService: mockAnalyticsService) {
            self.didCallAction = true
        }
        let exitButton: UIButton = try XCTUnwrap(errorView.view[child: "error-primary-button"])
        exitButton.sendActions(for: .touchUpInside)
        XCTAssertTrue(didCallAction)
    }
    
    func test_dataDeletedWarning_callsAction() throws {
        let errorView = sut.createDataDeletionWarning(analyticsService: mockAnalyticsService) {
            self.didCallAction = true
        }
        let exitButton: UIButton = try XCTUnwrap(errorView.view[child: "error-primary-button"])
        exitButton.sendActions(for: .touchUpInside)
        XCTAssertTrue(didCallAction)
    }
}
