@testable import DesignSystem
import GDSAnalytics
@testable import OneLogin
import Testing

@MainActor
struct SignOutConfirmationViewModelTests {
    var sut: SignOutConfirmationViewModel
    let mockAnalyticsService = MockAnalyticsService()
    
    init() {
        sut = SignOutConfirmationViewModel(analyticsService: mockAnalyticsService) {}
    }
    
    @Test
    func test_page() {
        let title = sut.body.first as? GDSTextViewModel
        #expect(title?.title.stringKey == "app_signOutConfirmationTitle")
        #expect(title?.title.value == "Are you sure you want to sign out?")
        #expect(title?.titleFont == .largeTitleBold)
        
        let body = sut.body[1] as? GDSTextViewModel
        #expect(body?.title.stringKey == "app_signOutConfirmationBody1")
        #expect(body?.title.value == "If you sign out, the information saved in your app will be deleted. This is to reduce the risk that someone else will see your information.")
        
        let bulletedList = sut.body[2] as? GDSListViewModel
        #expect(bulletedList?.title?.stringKey == "app_signOutConfirmationBody2")
        #expect(bulletedList?.title?.value == "This means:")
        #expect(bulletedList?.items == [GDSLocalisedString(stringKey: "app_signOutConfirmationBullet1"),
                                        GDSLocalisedString(stringLiteral: "app_signOutConfirmationBullet2"),
                                        GDSLocalisedString(stringLiteral: "app_signOutConfirmationBullet3")])
        
        let body2 = sut.body.last as? GDSTextViewModel
        #expect(body2?.title.stringKey == "app_signOutConfirmationBody3")
        #expect(body2?.title.value == "Next time you sign in, you’ll be able to add your documents again and reset your preferences.")
        
        #expect(sut.rightBarButtonTitle?.stringKey == "app_cancelButton")
        #expect(sut.rightBarButtonTitle?.value == "Cancel")
        
        #expect(sut.movableFooter.count == 1)
        #expect(sut.footer.count == 0)
        #expect(sut.backButtonTitle == nil)
        #expect(sut.backButtonIsHidden == true)
    }

    @Test
    func test_button() {
        var didCallButtonAction = false
        let sut = SignOutConfirmationViewModel(analyticsService: mockAnalyticsService) {
            didCallButtonAction = true
        }
        
        let button = sut.movableFooter.first as? GDSButtonViewModel
        #expect(button?.title.forState(.normal) == "Sign out and delete information")
        
        #expect(didCallButtonAction == false)
        #expect(mockAnalyticsService.eventsLogged.count == 0)
        button?.buttonAction.perform()
        #expect(didCallButtonAction)
        #expect(mockAnalyticsService.eventsLogged.count == 1)
        let event = ButtonEvent(textKey: "app_signOutAndDeleteAppDataButton")
        #expect(mockAnalyticsService.eventsLogged == [event.name.name])
        #expect(mockAnalyticsService.eventsParamsLogged == event.parameters)
    }
    
    @Test
    func test_didAppear() {
        #expect(mockAnalyticsService.screenViews.count == 0)
        let vc = GDSScreen(viewModel: sut)
        vc.viewDidAppear(false)
        #expect(mockAnalyticsService.screenViews.count == 1)
        let screen = ScreenView(id: SettingsAnalyticsScreenID.signOutScreen.rawValue,
                                screen: SettingsAnalyticsScreen.signOutScreen,
                                titleKey: "app_signOutErrorTitle")
        #expect(mockAnalyticsService.screenViews as? [ScreenView] == [screen])
        #expect(mockAnalyticsService.screenParamsLogged == screen.parameters)
    }
    
    @Test
    func test_didDismiss() {
        #expect(mockAnalyticsService.eventsLogged.count == 0)
        sut.didDismiss?.perform()
        #expect(mockAnalyticsService.eventsLogged.count == 1)
        let event = ButtonEvent(textKey: "app_cancelButton")
        #expect(mockAnalyticsService.eventsLogged == [event.name.name])
        #expect(mockAnalyticsService.eventsParamsLogged == event.parameters)
    }
}
