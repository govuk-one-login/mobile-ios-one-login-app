import GDSAnalytics
import GDSCommon
@testable import OneLogin
import Testing
import UIKit

@MainActor
struct LocalAuthSettingsErrorViewModelTests {
    let sut: LocalAuthSettingsErrorViewModel
    let mockAnalyticsService = MockAnalyticsService()
    let mockLocalAuthService = MockLocalAuthManager()
    let urlOpener = MockURLOpener()

    init() {
        sut = LocalAuthSettingsErrorViewModel(urlOpener: urlOpener,
                                      analyticsService: mockAnalyticsService,
                                      localAuthType: mockLocalAuthService.type)
    }
}

extension LocalAuthSettingsErrorViewModelTests {
    @Test
    func test_pageVariables() throws {
        #expect(sut.image == .error)
        #expect(sut.title.stringKey == "app_localAuthManagerErrorTitle")
        #expect(sut.title.value == "You need to update your phone settings")
        #expect(sut.bodyContent.count == 2)
        let bodyLabel = try #require(sut.bodyContent[0].uiView as? UILabel)
        #expect(bodyLabel.text == "To add documents, you need to protect your phone with a passcode.\n\nThis is to make sure no one else can view or add documents to your app.")
        #expect(sut.buttonViewModels.count == 1)
        #expect(sut.buttonViewModels[0].title.stringKey == "app_localAuthManagerErrorGoToSettingsButton")
        #expect(sut.buttonViewModels[0].title.value == "Go to phone settings")
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
