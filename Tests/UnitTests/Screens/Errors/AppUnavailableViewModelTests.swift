@testable import DesignSystem
import GDSAnalytics
@testable import OneLogin
import Testing

@MainActor
struct AppUnavailableViewModelTests {
    let sut: AppUnavailableViewModel
    let mockAnalyticsService = MockAnalyticsService()

    init() {
        sut = AppUnavailableViewModel(analyticsService: mockAnalyticsService)
    }
    
    @Test
    func test_page() throws {
        let title = sut.body.first as? GDSErrorIconTitleViewModel
        
        #expect(title?.icon == .error)
        #expect(title?.errorTitle.title.stringKey == "app_appUnavailableTitle")
        #expect(title?.errorTitle.title.value == "Sorry, the app is unavailable")
        #expect(title?.errorTitle.titleFont == .largeTitleBold)
        #expect(title?.errorTitle.alignment == .center)
        #expect(title?.errorTitle.accessibilityTraits == .header)
        
        let body = sut.body.last as? GDSTextViewModel
        #expect(body?.title.stringKey == "app_appUnavailableBody")
        #expect(body?.title.variableKeys == ["app_nameString"])
        #expect(body?.title.value == "You cannot use the GOV.UK One Login app at the moment.\n\nTry again later.")
        #expect(body?.alignment == .center)
                       
        #expect(sut.movableFooter.count == 0)
        #expect(sut.footer.count == 0)
        #expect(sut.rightBarButtonTitle == nil)
        #expect(sut.backButtonTitle == nil)
        #expect(sut.backButtonIsHidden == true)
        #expect(sut.didDismiss == nil)
    }
    
    @Test
    func test_didAppear() {
        #expect(mockAnalyticsService.screenViews.count == 0)
        let vc = GDSScreen(viewModel: sut)
        vc.viewDidAppear(false)
        #expect(mockAnalyticsService.screenViews.count == 1)
        let screen = ErrorScreenView(id: ErrorAnalyticsScreenID.appUnavailable.rawValue,
                                     screen: ErrorAnalyticsScreen.appUnavailable,
                                     titleKey: "app_appUnavailableTitle",
                                     reason: "app unavailable error")
        #expect(mockAnalyticsService.screenViews as? [ErrorScreenView] == [screen])
        #expect(mockAnalyticsService.screenParamsLogged == screen.parameters)
    }
}
