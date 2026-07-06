@testable import DesignSystem
import GDSAnalytics
@testable import OneLogin
import Testing

@MainActor
struct UnrecoverableLoginErrorViewModelTests {
    let sut: UnrecoverableLoginErrorViewModel
    let mockAnalyticsService = MockAnalyticsService()

    init() {
        sut = UnrecoverableLoginErrorViewModel(analyticsService: mockAnalyticsService,
                                               errorDescription: "error description")
    }
    
    @Test
    func test_page() throws {
        let title = sut.body.first as? GDSErrorIconTitleViewModel
        
        #expect(title?.icon == .error)
        #expect(title?.errorTitle.title.stringKey == "app_signInErrorTitle")
        #expect(title?.errorTitle.title.value == "There was a problem signing you in")
        #expect(title?.errorTitle.titleFont == .largeTitleBold)
        #expect(title?.errorTitle.alignment == .center)
        
        let body = sut.body.last as? GDSTextViewModel
        #expect(body?.title.stringKey == "app_signInErrorUnrecoverableBody")
        #expect(body?.title.value == "Try again later.")
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
        let screen = ErrorScreenView(id: ErrorAnalyticsScreenID.unrecoverableLoginError.rawValue,
                                     screen: ErrorAnalyticsScreen.unrecoverablLoginError,
                                     titleKey: "app_signInErrorTitle",
                                     reason: "error description")
        #expect(mockAnalyticsService.screenViews as? [ErrorScreenView] == [screen])
        #expect(mockAnalyticsService.screenParamsLogged == screen.parameters)
    }
}
