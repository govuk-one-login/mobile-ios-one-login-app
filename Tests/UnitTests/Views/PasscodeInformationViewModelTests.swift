import GDSAnalytics
@testable import OneLogin
import XCTest

final class PasscodeInformationViewModelTests: XCTestCase {
    var mockAnalyticsService: MockAnalyticsService!
    var sut: PasscodeInformationViewModel!
    var didCallButtonAction = false
    
    override func setUp() {
        super.setUp()
        
        mockAnalyticsService = MockAnalyticsService()
        sut = PasscodeInformationViewModel(analyticsService: mockAnalyticsService) {
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

extension PasscodeInformationViewModelTests {
    func test_labelContents() throws {
        XCTAssertEqual(sut.image, "lock")
        XCTAssertEqual(sut.title.value, "You can sign in with a passcode")
        XCTAssertEqual(sut.body.value, "Add a layer of security and sign in with a passcode instead of your email address and password. \n\n You can set a passcode later by going to your phone settings.")
    }
    
    func test_buttonAction() throws {
        XCTAssertFalse(didCallButtonAction)
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 0)
        sut.primaryButtonViewModel.action()
        XCTAssertTrue(didCallButtonAction)
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 1)
        let event = ButtonEvent(textKey: sut.primaryButtonViewModel.title.value)
        XCTAssertEqual(mockAnalyticsService.eventsLogged, [event.name.name])
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged["text"], event.parameters["text"])
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged["type"], event.parameters["type"])
    }
    
    func test_didAppear() throws {
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 0)
        sut.didAppear()
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 1)
        let screen = ScreenView(screen: InformationAnalyticsScreen.passcode,
                                titleKey: "You can sign in with a passcode")
        XCTAssertEqual(mockAnalyticsService.screensVisited, [screen.screen.name])
        XCTAssertEqual(mockAnalyticsService.screenParamsLogged["title"], screen.parameters["title"])
    }
}
