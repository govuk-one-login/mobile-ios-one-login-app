import GDSAnalytics
@testable import OneLogin
import XCTest

@MainActor
final class LocalAuthBiometricsErrorViewModelTests: XCTestCase {
    var mockAnalyticsService: MockAnalyticsService!
    var sut: LocalAuthBiometricsErrorViewModel!
    
    var didCallButtonAction = false
    
    override func setUp() {
        super.setUp()
        
        mockAnalyticsService = MockAnalyticsService()
        sut = LocalAuthBiometricsErrorViewModel(analyticsService: mockAnalyticsService, localAuthType: .faceID) {
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

extension LocalAuthBiometricsErrorViewModelTests {
    func test_page() {
        XCTAssertEqual(sut.image, .error)
        XCTAssertEqual(sut.title.stringKey, "app_localAuthManagerBiometricsErrorTitle")
        XCTAssertEqual(sut.bodyContent.count, 1)
        XCTAssertEqual(sut.rightBarButtonTitle?.stringKey, "app_cancelButton")
        XCTAssertTrue(sut.backButtonIsHidden)
    }
    
    func test_button() {
        XCTAssertEqual(sut.buttonViewModels[0].title.stringKey, "app_enableBiometricsTitle")
        XCTAssertFalse(didCallButtonAction)
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 0)
        sut.buttonViewModels[0].action()
        XCTAssertTrue(didCallButtonAction)
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 1)
        let event = ButtonEvent(textKey: "allow face id")
        XCTAssertEqual(mockAnalyticsService.eventsLogged, [event.name.name])
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged, event.parameters)
    }
    
    func test_didAppear() {
        // TODO: DCMAW-12769 Implement analytics
    }
}
