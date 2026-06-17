@testable import DesignSystem
import GDSAnalytics
@testable import OneLogin
import Testing

@MainActor
struct GenericErrorViewModelTests {
    var sut: GenericErrorViewModel
    let mockAnalyticsService = MockAnalyticsService()
    
    init() {
        sut = GenericErrorViewModel(analyticsService: mockAnalyticsService,
                                    errorDescription: "error description") {}
    }
    
    @Test
    func test_page() {
        let title = sut.body.first as? GDSErrorIconTitleViewModel
        #expect(title?.icon == .error)
        #expect(title?.errorTitle.title.stringKey == "app_genericErrorPage")
        #expect(title?.errorTitle.title.value == "Sorry, there’s a problem")
        #expect(title?.errorTitle.titleFont == .largeTitleBold)
        #expect(title?.errorTitle.alignment == .center)
        
        let body = sut.body.last as? GDSTextViewModel
        #expect(body?.title.stringKey == "app_genericErrorPageBody")
        #expect(body?.title.value == "Try again later.")
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
        let sut = GenericErrorViewModel(analyticsService: mockAnalyticsService,
                                        errorDescription: "error description") {
            didCallButtonAction = true
        }
        
        let button = sut.movableFooter.first as? GDSButtonViewModel
        #expect(button?.title.forState(.normal) == "Go back and try again")
        
        #expect(didCallButtonAction == false)
        #expect(mockAnalyticsService.eventsLogged.count == 0)
        button?.buttonAction.perform()
        #expect(didCallButtonAction)
        #expect(mockAnalyticsService.eventsLogged.count == 1)
        let event = ButtonEvent(textKey: "app_tryAgainButton")
        #expect(mockAnalyticsService.eventsLogged == [event.name.name])
        #expect(mockAnalyticsService.eventsParamsLogged == event.parameters)
    }
    
    @Test
    func test_didAppear() {
        #expect(mockAnalyticsService.screenViews.count == 0)
        let vc = GDSScreen(viewModel: sut)
        vc.viewDidAppear(false)
        #expect(mockAnalyticsService.screenViews.count == 1)
        let screen = ErrorScreenView(id: ErrorAnalyticsScreenID.generic.rawValue,
                                     screen: ErrorAnalyticsScreen.generic,
                                     titleKey: "app_genericErrorPage",
                                     reason: "error description")
        #expect(mockAnalyticsService.screenViews as? [ErrorScreenView] == [screen])
        #expect(mockAnalyticsService.screenParamsLogged == screen.parameters)
    }
}
