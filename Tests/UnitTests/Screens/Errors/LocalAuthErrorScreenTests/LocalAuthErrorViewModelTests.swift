import GDSAnalytics
@testable import OneLogin
import Testing
import UIKit

@MainActor
struct LocalAuthErrorViewModelTests {
    let sut: LocalAuthErrorViewModel
    let mockAnalyticsService = MockAnalyticsService()
    let mockLocalAuthService = MockLocalAuthManager()
    let urlOpener = MockURLOpener()

    init() {
        sut = LocalAuthErrorViewModel(urlOpener: urlOpener,
                                      analyticsService: mockAnalyticsService,
                                      localAuthType: mockLocalAuthService.type)
    }
}

extension LocalAuthErrorViewModelTests {
    @Test
    func test_pageVariables() {
        #expect(sut.image == .error)
        #expect(sut.title.stringKey == "app_localAuthManagerErrorTitle")
        #expect(sut.bodyContent.count == 2)
        #expect(sut.buttonViewModels.count == 1)
        #expect(sut.buttonViewModels[0].title.stringKey == "app_localAuthManagerErrorGoToSettingsButton")
        #expect(sut.rightBarButtonTitle != nil)
        #expect(sut.backButtonIsHidden)
    }
    
    @Test
    func test_primaryButton_action() {
        #expect(mockAnalyticsService.eventsLogged.count == 0)
        #expect(urlOpener.didOpenURL == false)
        
        sut.buttonViewModels[0].action()
        let event = ButtonEvent(textKey: "app_localAuthManagerErrorGoToSettingsButton")
        
        #expect(mockAnalyticsService.eventsLogged.count == 1)
        #expect(mockAnalyticsService.eventsLogged == [event.name.name])
        #expect(mockAnalyticsService.eventsParamsLogged == event.parameters)
        #expect(urlOpener.didOpenURL)
    }
    
    @Test
    func test_didAppear() {
        #expect(mockAnalyticsService.screensVisited.count == 0)
        
        sut.didAppear()
        let screen = ErrorScreenView(id: ErrorAnalyticsScreenID.updateTouchID.rawValue,
                                     screen: ErrorAnalyticsScreen.updateTouchID,
                                     titleKey: "app_localAuthManagerErrorTitle")
        
        #expect(mockAnalyticsService.screensVisited.count == 1)
        #expect(mockAnalyticsService.screensVisited == [screen.name])
        #expect(mockAnalyticsService.screenParamsLogged == screen.parameters)
    }
    
    @Test
    func test_didDismiss() {
        #expect(mockAnalyticsService.eventsLogged.count == 0)

        sut.didDismiss()
        let event = IconEvent(textKey: "back - system")
        
        #expect(mockAnalyticsService.eventsLogged.count == 1)
        #expect(mockAnalyticsService.eventsLogged == [event.name.name])
        #expect(mockAnalyticsService.eventsParamsLogged == event.parameters)
    }
}
