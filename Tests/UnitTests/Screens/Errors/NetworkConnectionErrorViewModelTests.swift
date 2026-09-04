@testable import DesignSystem
import GDSAnalytics
@testable import OneLogin
import Testing

@MainActor
struct NetworkConnectionErrorViewModelTests {
    var sut: NetworkConnectionErrorViewModel
    let mockAnalyticsService = MockAnalyticsService()
    
    init() {
        sut = NetworkConnectionErrorViewModel(analyticsService: mockAnalyticsService) {}
    }
    
    @Test
    func test_page() throws {
        let title = sut.body.first as? GDSErrorIconTitleViewModel
        
        #expect(title?.icon == .error)
        #expect(title?.errorTitle.title.stringKey == "app_networkErrorTitle")
        #expect(title?.errorTitle.title.value == "You are not connected to the internet")
        #expect(title?.errorTitle.titleFont == .largeTitleBold)
        #expect(title?.errorTitle.alignment == .center)
        #expect(title?.errorTitle.accessibilityTraits == .header)
        
        let body = sut.body.last as? GDSTextViewModel
        #expect(body?.title.stringKey == "app_networkErrorBody")
        #expect(body?.title.variableKeys == ["app_nameString"])
        #expect(body?.title.value == "You need to have an internet connection to use GOV.UK One Login.\n\nReconnect to the internet and try again.")
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
        let sut = NetworkConnectionErrorViewModel(analyticsService: mockAnalyticsService) {
            didCallButtonAction = true
        }
        
        let button = sut.movableFooter.first as? GDSButtonViewModel
        #expect(button?.title.forState(.normal) == "Go back and try again")
        
        #expect(didCallButtonAction == false)
        #expect(mockAnalyticsService.eventsLogged.count == 0)
        button?.buttonAction.perform()
        #expect(didCallButtonAction == true)
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
        let screen = ErrorScreenView(id: ErrorAnalyticsScreenID.networkConnection.rawValue,
                                     screen: ErrorAnalyticsScreen.networkConnection,
                                     titleKey: "app_networkErrorTitle",
                                     reason: "network connection error")
        #expect(mockAnalyticsService.screenViews as? [ErrorScreenView] == [screen])
        #expect(mockAnalyticsService.screenParamsLogged == screen.parameters)
    }
}
