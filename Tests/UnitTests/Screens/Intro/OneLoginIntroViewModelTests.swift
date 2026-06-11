@testable import DesignSystem
import GDSAnalytics
@testable import OneLogin
import Testing
import UIKit

@MainActor
struct OneLoginIntroViewModelTests {
    var mockAnalyticsService: MockAnalyticsService!
    var sut: OneLoginIntroViewModel!
    
    init() {
        mockAnalyticsService = MockAnalyticsService()
        sut = OneLoginIntroViewModel(analyticsService: mockAnalyticsService) { nil }
    }
}

extension OneLoginIntroViewModelTests {
    @Test
    func test_page() {
        let imageVM = sut.body.first as? GDSImageViewModel
        let titleText = sut.body[1] as? GDSTextViewModel
        let bodyText = sut.body[2] as? GDSTextViewModel
        #expect(imageVM?.image == UIImage(named: "badge"))
        #expect(titleText?.title.stringKey == "app_nameString")
        #expect(titleText?.title.value == "GOV.UK One Login")
        #expect(titleText?.alignment == .center)
        #expect(bodyText?.title.stringKey == "app_signInBody")
        #expect(bodyText?.title.variableKeys == ["app_nameString"])
        #expect(bodyText?.title.value == "Prove your identity to access government services.\n\nYou’ll need to sign in with your GOV.UK One Login details.")
        #expect(bodyText?.alignment == .center)
        #expect(sut.movableFooter.count == 1)
        #expect(sut.footer.count == 0)
        #expect(sut.rightBarButtonTitle == nil)
        #expect(sut.backButtonTitle == nil)
        #expect(sut.backButtonIsHidden)
        #expect(sut.didDismiss == nil)
    }
    
    @Test
    func test_button() async {
        var didCallButtonAction = false
        
        let sut = OneLoginIntroViewModel(analyticsService: mockAnalyticsService) {
            Task {
                didCallButtonAction = true
            }
        }
        let primaryButton = sut.movableFooter.first as? GDSButtonViewModel
        #expect(primaryButton?.title.forState(.normal) == "Sign in with GOV.UK One Login")
        #expect(!didCallButtonAction)
        #expect(mockAnalyticsService.eventsLogged.count == 0)
        
        await primaryButton?.buttonAction.performAsync()
        
        #expect(didCallButtonAction)
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
        #expect(sut.didDismiss == nil)
        #expect(mockAnalyticsService.screenViews.count == 0)
        let vc = GDSScreen(viewModel: sut)
        vc.viewDidAppear(false)
        #expect(mockAnalyticsService.screenViews.count == 1)
        let screen = ScreenView(id: IntroAnalyticsScreenID.welcome.rawValue,
                                screen: IntroAnalyticsScreen.welcome,
                                titleKey: "app_nameString")
        #expect(mockAnalyticsService.screenViews as? [ScreenView] == [screen])
        #expect(mockAnalyticsService.screenParamsLogged == screen.parameters)
    }
}
