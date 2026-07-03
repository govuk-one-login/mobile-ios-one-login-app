@testable import DesignSystem
import GDSAnalytics
@testable import OneLogin
import Testing

@MainActor
struct SignInAgainViewModelTests {
    var sut: SignInAgainViewModel
    let mockAnalyticsService = MockAnalyticsService()
    
    init() {
        sut = SignInAgainViewModel(analyticsService: mockAnalyticsService) { nil }
    }
    
    @Test
    func test_page() throws {
        let title = sut.body.first as? GDSTextViewModel
        #expect(title?.title.stringKey == "app_signInAgainTitle")
        #expect(title?.title.value == "You need to sign in again")
        #expect(title?.titleFont == .largeTitleBold)
        #expect(title?.alignment == .center)
        
        let body = sut.body.last as? GDSTextViewModel
        #expect(body?.title.stringKey == "app_signInAgainBody")
        #expect(body?.title.variableKeys == ["app_nameString"])
        #expect(body?.title.value == "Sign in with your GOV.UK One Login details to continue.\n\nThis is to keep your information secure.")
        #expect(body?.alignment == .center)
        
        #expect(sut.movableFooter.count == 1)
        #expect(sut.footer.count == 0)
        #expect(sut.rightBarButtonTitle == nil)
        #expect(sut.backButtonTitle == nil)
        #expect(sut.backButtonIsHidden == true)
        #expect(sut.didDismiss == nil)
    }
    
    @Test
    func test_button() async {
        var didCallButtonAction = false
        let sut = SignInAgainViewModel(analyticsService: mockAnalyticsService) {
            Task {
                didCallButtonAction = true
            }
        }
        
        let button = sut.movableFooter.first as? GDSButtonViewModel
        #expect(button?.title.forState(.normal) == "Sign in with GOV.UK One Login")
        
        #expect(didCallButtonAction == false)
        #expect(mockAnalyticsService.eventsLogged.count == 0)
        await button?.buttonAction.performAsync()
        #expect(didCallButtonAction == true)
        #expect(mockAnalyticsService.eventsLogged.count == 1)
        let event = LinkEvent(textKey: "app_extendedSignInButton",
                              variableKeys: "app_nameString",
                              linkDomain: AppEnvironment.mobileBaseURLString,
                              external: .false)
        #expect(mockAnalyticsService.eventsLogged == [event.name.name])
        #expect(mockAnalyticsService.eventsParamsLogged == event.parameters)
    }
    
    @Test
    func test_didAppear() {
        #expect(mockAnalyticsService.screenViews.count == 0)
        let vc = GDSScreen(viewModel: sut)
        vc.viewDidAppear(false)
        #expect(mockAnalyticsService.screenViews.count == 1)
        let screen = ScreenView(id: IntroAnalyticsScreenID.signInAgain.rawValue,
                                screen: IntroAnalyticsScreen.signInAgain,
                                titleKey: "app_signInAgainTitle")
        #expect(mockAnalyticsService.screenViews as? [ScreenView] == [screen])
        #expect(mockAnalyticsService.screenParamsLogged == screen.parameters)
    }
}
