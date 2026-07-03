import GDSAnalytics
@testable import OneLogin
import Testing

@MainActor
struct UnlockScreenViewModelTests {
    var mockAnalyticsService: MockAnalyticsService!
    var sut: UnlockScreenViewModel!
    
    init() {
        mockAnalyticsService = MockAnalyticsService()
        sut = UnlockScreenViewModel(analyticsService: mockAnalyticsService) {}
    }
}

extension UnlockScreenViewModelTests {
    func test_button() {
        var didCallPrimaryButtonAction = false
        let sut = UnlockScreenViewModel(analyticsService: mockAnalyticsService) {
            didCallPrimaryButtonAction = true
        }
        
        #expect(sut.primaryButtonTitle == "Unlock")
        #expect(!didCallPrimaryButtonAction)
        #expect(mockAnalyticsService.eventsLogged.count == 0)
        sut.primaryButtonAction()
        #expect(didCallPrimaryButtonAction)
        #expect(mockAnalyticsService.eventsLogged.count == 1)
        let event = ButtonEvent(textKey: "app_unlockButton")
        #expect(mockAnalyticsService.eventsLogged == [event.name.name])
        #expect(mockAnalyticsService.eventsParamsLogged == event.parameters)
    }

    func test_didAppear() {
        #expect(mockAnalyticsService.screenViews.count == 0)
        sut.didAppear?.perform()
        #expect(mockAnalyticsService.screenViews.count == 1)
        let screen = ScreenView(id: BiometricEnrolmentAnalyticsScreenID.unlock.rawValue,
                                screen: BiometricEnrolmentAnalyticsScreen.unlock,
                                titleKey: "one login unlock screen")
        #expect(mockAnalyticsService.screenViews as? [ScreenView] == [screen])
        #expect(mockAnalyticsService.screenParamsLogged == screen.parameters)
    }
}
