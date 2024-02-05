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
        XCTAssertEqual(sut.title.value, "It looks like this phone does not have a passcode")
        XCTAssertEqual(sut.body!.value, """
Setting a passcode on your phone adds further security. You can then sign into the app this way instead of with your email address and password.

You can set a passcode later by going to your phone settings.
""")
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
                                titleKey: "It looks like this phone does not have a passcode")
        XCTAssertEqual(mockAnalyticsService.screensVisited, [screen.screen.name])
        XCTAssertEqual(mockAnalyticsService.screenParamsLogged["title"], screen.parameters["title"])
    }
}
