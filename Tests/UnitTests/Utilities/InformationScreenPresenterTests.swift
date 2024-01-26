@testable import OneLogin
import XCTest

final class InformationScreenPresenterTests: XCTestCase {
    var mockAnalyticsService: MockAnalyticsService!
    var sut: InformationScreenPresenter.Type!
    var didCallAction = false
    
    override func setUp() {
        super.setUp()
        
        mockAnalyticsService = MockAnalyticsService()
        sut = InformationScreenPresenter.self
    }
    
    override func tearDown() {
        mockAnalyticsService = nil
        sut = nil
        
        super.tearDown()
    }
}

extension InformationScreenPresenterTests {
    func test_noPasscodeCallsAction() throws {
        let introView = sut.createPasscodeInformationScreen(analyticsService: mockAnalyticsService){
            self.didCallAction = true
        }
        let introButton: UIButton = try XCTUnwrap(introView.view[child: "information-primary-button"])
        introButton.sendActions(for: .touchUpInside)
        XCTAssertTrue(didCallAction)
    }
}
