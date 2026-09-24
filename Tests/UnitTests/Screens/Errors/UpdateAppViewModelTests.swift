@testable import DesignSystem
import GDSAnalytics
@testable import OneLogin
import Testing

@MainActor
struct UpdateAppViewModelTests {
    var mockAnalyticsService: MockAnalyticsService!
    var urlOpener: MockURLOpener!
    var sut: UpdateAppViewModel!

    init() {
        mockAnalyticsService = MockAnalyticsService()
        urlOpener = .init()
        sut = UpdateAppViewModel(analyticsService: mockAnalyticsService,
                                 urlOpener: urlOpener)
    }
}

extension UpdateAppViewModelTests {
    @Test
    func test_page() {
        let title = sut.body.first as? GDSErrorIconTitleViewModel
        
        #expect(title?.icon == .update)
        #expect(title?.errorTitle.title.stringKey == "app_updateAppTitle")
        #expect(title?.errorTitle.title.value == "You need to update your app")
        #expect(title?.errorTitle.titleFont == .largeTitleBold)
        #expect(title?.errorTitle.alignment == .center)
        #expect(title?.errorTitle.accessibilityTraits == .header)
        
        let bodyText = sut.body.last as? GDSTextViewModel
        #expect(bodyText?.title.stringKey == "app_updateAppBody")
        #expect(bodyText?.title.variableKeys == ["app_nameString"])
        #expect(bodyText?.title.value == "You're using an old version of the GOV.UK One Login app.\n\nGo to the App Store and update your app to continue.")
        #expect(sut.rightBarButtonTitle == nil)
        #expect(sut.backButtonIsHidden)
    }

    @Test
    func test_button() {
        let primaryButton = sut.movableFooter.first as? GDSButtonViewModel
        
        #expect(primaryButton?.title.forState(.normal) == "Go to App Store")
        #expect(primaryButton?.icon == .arrowUpRight)
        #expect(primaryButton?.accessibilityHint == "Opens in App Store")
        #expect(!urlOpener.didOpenURL)
        primaryButton?.buttonAction.perform()
        #expect(urlOpener.didOpenURL)
        
        let event = LinkEvent(textKey: "app_updateAppButton",
                              variableKeys: "app_nameString",
                              linkDomain: AppEnvironment.appStore.absoluteString,
                              external: .true)
        #expect(mockAnalyticsService.eventsLogged == [event.name.name])
        #expect(mockAnalyticsService.eventsParamsLogged == event.parameters)
        #expect(mockAnalyticsService.additionalParameters[OLTaxonomyKey.level2] as? String == OLTaxonomyValue.system)
    }
    
    @Test
    func test_didAppear() {
        let sut = UpdateAppViewModel(analyticsService: mockAnalyticsService,
                                     urlOpener: urlOpener)
        let vc = GDSScreen(viewModel: sut)
        
        #expect(sut.didDismiss == nil)
        #expect(mockAnalyticsService.screenViews.count == 0)
        vc.viewDidAppear(false)
        #expect(mockAnalyticsService.screenViews.count == 1)
        let screen = ErrorScreenView(id: IntroAnalyticsScreenID.updateApp.rawValue,
                                     screen: IntroAnalyticsScreen.updateApp,
                                     titleKey: "app_updateAppTitle",
                                     reason: "update required error")
        #expect(mockAnalyticsService.screenViews as? [ErrorScreenView] == [screen])
        #expect(mockAnalyticsService.screenParamsLogged == screen.parameters)
    }
}
