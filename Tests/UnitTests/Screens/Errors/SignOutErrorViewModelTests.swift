@testable import DesignSystem
import GDSAnalytics
@testable import OneLogin
import Testing

@MainActor
struct SignOutErrorViewModelTests {
    var sut: SignOutErrorViewModel
    let mockAnalyticsService = MockAnalyticsService()
    
    init() {
        sut = SignOutErrorViewModel(analyticsService: mockAnalyticsService,
                                    error: MockWalletError.cantDelete) { }
    }
    
    @Test
    func test_page() throws {
        let title = sut.body.first as? GDSErrorIconTitleViewModel
        #expect(title?.icon == .error)
        #expect(title?.errorTitle.title.stringKey == "app_signOutErrorTitle")
        #expect(title?.errorTitle.title.value == "There was a problem signing you out")
        #expect(title?.errorTitle.titleFont == .largeTitleBold)
        #expect(title?.errorTitle.alignment == .center)
        
        let body = sut.body.last as? GDSTextViewModel
        #expect(body?.title.stringKey == "app_signOutErrorBody")
        // swiftlint:disable line_length
        #expect(body?.title.value == "Try again later.\n\nIf you need to sign out right now, you can delete the app from your phone. This will also delete any documents saved in your app.")
        // swiftlint:enable line_length
        #expect(body?.alignment == .center)
        
        #expect(sut.movableFooter.count == 1)
        #expect(sut.footer.count == 0)
        #expect(sut.rightBarButtonTitle == nil)
        #expect(sut.backButtonTitle == nil)
        #expect(sut.backButtonIsHidden == true)
        #expect(sut.didDismiss == nil)
    }
    
    @Test
    func test_button() {
        var didCallButtonAction = false
        let sut = SignOutErrorViewModel(analyticsService: mockAnalyticsService,
                                        error: MockWalletError.cantDelete) {
            didCallButtonAction = true
        }
        
        let button = sut.movableFooter.first as? GDSButtonViewModel
        #expect(button?.title.forState(.normal) == "Go back to settings")
        
        #expect(didCallButtonAction == false)
        #expect(mockAnalyticsService.eventsLogged.count == 0)
        button?.buttonAction.perform()
        #expect(didCallButtonAction == true)
        #expect(mockAnalyticsService.eventsLogged.count == 1)
        let event = ButtonEvent(textKey: "app_signOutErrorButton")
        #expect(mockAnalyticsService.eventsLogged == [event.name.name])
        #expect(mockAnalyticsService.eventsParamsLogged == event.parameters)
    }
    
    @Test
    func test_didAppear() {
        #expect(mockAnalyticsService.crashesLogged.count == 0)
        #expect(mockAnalyticsService.screenViews.count == 0)
        let vc = GDSScreen(viewModel: sut)
        vc.viewDidAppear(false)
        #expect(mockAnalyticsService.crashesLogged.count == 1)
        #expect(mockAnalyticsService.crashesLogged.first as? MockWalletError == .cantDelete)
        
        #expect(mockAnalyticsService.screenViews.count == 1)
        let screen = ErrorScreenView(id: ErrorAnalyticsScreenID.signOut.rawValue,
                                     screen: ErrorAnalyticsScreen.signOut,
                                     titleKey: "app_signOutErrorTitle",
                                     reason: MockWalletError.cantDelete.localizedDescription)
        #expect(mockAnalyticsService.screenViews as? [ErrorScreenView] == [screen])
        #expect(mockAnalyticsService.screenParamsLogged == screen.parameters)
    }
}
