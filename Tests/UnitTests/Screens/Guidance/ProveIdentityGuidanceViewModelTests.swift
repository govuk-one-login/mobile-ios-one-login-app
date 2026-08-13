@testable import DesignSystem
import GDSAnalytics
@testable import OneLogin
import Testing

@MainActor
struct ProveIdentityGuidanceViewModelTests {
    var mockAnalyticsService: MockAnalyticsService!
    var urlOpener: MockURLOpener!
    var sut: ProveIdentityGuidanceViewModel!
    
    init() {
        mockAnalyticsService = MockAnalyticsService()
        urlOpener = .init()
        sut = ProveIdentityGuidanceViewModel(analyticsService: mockAnalyticsService,
                                             urlOpener: urlOpener)
    }
}

extension ProveIdentityGuidanceViewModelTests {
    @Test
    func test_prove_identity_page() {
        let titleText = sut.body.first as? GDSTextViewModel
        let body1 = sut.body[1] as? GDSTextViewModel
        let button = sut.body[2] as? GDSButtonViewModel
        let body2 = sut.body[3] as? GDSTextViewModel
        let body3 = sut.body[4] as? GDSTextViewModel

        #expect(titleText?.title.stringKey == "app_proveYourIdentityGuidanceTitle")
        #expect(titleText?.title.value == "How to prove your identity")
        #expect(body1?.title.stringKey == "app_proveYourIdentityGuidanceBody1")
        #expect(button?.title.forState(.normal) == "Go to the GOV.UK website")
        #expect(button?.icon == .arrowUpRight)
        #expect(button?.accessibilityHint == "Opens in web browser")
        #expect(body2?.title.stringKey == "app_proveYourIdentityGuidanceBody2")
        #expect(body3?.title.stringKey == "app_proveYourIdentityGuidanceBody3")
        #expect(sut.rightBarButtonTitle == "app_doneButton")
        #expect(sut.movableFooter.isEmpty)
        #expect(sut.backButtonIsHidden)
    }
    
    @Test
    func test_button() {
        let button = sut.body[2] as? GDSButtonViewModel

        #expect(!urlOpener.didOpenURL)
        button?.buttonAction.perform()
        #expect(urlOpener.didOpenURL)
        
        let event = LinkEvent(textKey: "app_proveYourIdentityGuidanceLink",
                              linkDomain: AppEnvironment.govSignInURL.absoluteString,
                              external: .true)
        #expect(mockAnalyticsService.eventsLogged == [event.name.name])
        #expect(mockAnalyticsService.eventsParamsLogged == event.parameters)
        #expect(mockAnalyticsService.additionalParameters[OLTaxonomyKey.level2] as? String == OLTaxonomyValue.home)
    }
    
    @Test
    func test_didAppear() {
        let vc = GDSScreen(viewModel: sut)
        
        #expect(mockAnalyticsService.screenViews.count == 0)
        vc.viewDidAppear(false)
        #expect(mockAnalyticsService.screenViews.count == 1)
        let screen = ScreenView(id: HomeAnalyticsScreenID.proveIdentityGuidance.rawValue,
                                screen: HomeAnalyticsScreen.proveIdentityGuidance,
                                titleKey: "app_proveYourIdentityGuidanceTitle")
        #expect(mockAnalyticsService.screenViews as? [ScreenView] == [screen])
        #expect(mockAnalyticsService.screenParamsLogged == screen.parameters)
    }
    
    @Test
    func test_didDismiss() {
        #expect(mockAnalyticsService.eventsLogged.count == 0)
        sut.didDismiss?.perform()
        #expect(mockAnalyticsService.eventsLogged.count == 1)
        let event = ButtonEvent(textKey: "app_doneButton")
        #expect(mockAnalyticsService.eventsLogged == [event.name.name])
        #expect(mockAnalyticsService.eventsParamsLogged == event.parameters)
    }
}
