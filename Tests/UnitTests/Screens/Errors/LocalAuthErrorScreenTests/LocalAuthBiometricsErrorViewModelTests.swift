@testable import DesignSystem
import GDSAnalytics
@testable import OneLogin
import Testing

@MainActor
struct LocalAuthBiometricsErrorViewModelTests {
    var mockAnalyticsService: MockAnalyticsService!
    var sut: LocalAuthBiometricsErrorViewModel!
        
    init() {
        mockAnalyticsService = MockAnalyticsService()
        sut = LocalAuthBiometricsErrorViewModel(analyticsService: mockAnalyticsService, localAuthType: .faceID) {}
    }
}

extension LocalAuthBiometricsErrorViewModelTests {
    @Test
    func test_page_faceID() {
        let title = sut.body.first as? GDSErrorIconTitleViewModel
        let bodyText = sut.body[1] as? GDSTextViewModel
        let primaryButton = sut.movableFooter.first as? GDSButtonViewModel
        
        #expect(title?.icon == .error)
        #expect(title?.errorTitle.title.stringKey == "app_localAuthManagerBiometricsErrorTitle")
        #expect(title?.errorTitle.title.value == "You need to allow Face ID")
        #expect(title?.errorTitle.titleFont == .largeTitleBold)
        #expect(title?.errorTitle.alignment == .center)
        #expect(title?.errorTitle.accessibilityTraits == .header)
        #expect(bodyText?.title.stringKey == "app_localAuthManagerBiometricsFaceIDErrorBody")
        #expect(bodyText?.alignment == .center)
        #expect(primaryButton?.title.forState(.normal) == "Allow Face ID")
        #expect(sut.movableFooter.count == 1)
        #expect(sut.footer.count == 0)
        #expect(sut.rightBarButtonTitle != nil)
        #expect(sut.backButtonTitle == nil)
        #expect(sut.backButtonIsHidden)
    }
    
    @Test
    func test_page_touchID() {
        let sut = LocalAuthBiometricsErrorViewModel(analyticsService: mockAnalyticsService, localAuthType: .touchID) {}
        
        let title = sut.body.first as? GDSErrorIconTitleViewModel
        let bodyText = sut.body[1] as? GDSTextViewModel
        let primaryButton = sut.movableFooter.first as? GDSButtonViewModel
        
        #expect(title?.errorTitle.title.stringKey == "app_localAuthManagerBiometricsErrorTitle")
        #expect(title?.errorTitle.title.value == "You need to allow Touch ID")
        #expect(bodyText?.title.stringKey == "app_localAuthManagerBiometricsTouchIDErrorBody")
        #expect(bodyText?.alignment == .center)
        #expect(primaryButton?.title.forState(.normal) == "Allow Touch ID")
        #expect(sut.movableFooter.count == 1)
    }
    
    @Test
    func test_primary_button() async {
        var didCallPrimaryButtonAction = false
        
        let sut = LocalAuthBiometricsErrorViewModel(analyticsService: mockAnalyticsService, localAuthType: .faceID) {
            didCallPrimaryButtonAction = true
        }

        let primaryButton = sut.movableFooter[0] as? GDSButtonViewModel
        
        #expect(!didCallPrimaryButtonAction)
        #expect(mockAnalyticsService.eventsLogged.count == 0)
        await primaryButton?.buttonAction.performAsync()
        #expect(didCallPrimaryButtonAction)
        #expect(mockAnalyticsService.eventsLogged.count == 1)
        let event = ButtonEvent(textKey: "allow face id")
        #expect(mockAnalyticsService.eventsLogged == [event.name.name])
        #expect(mockAnalyticsService.eventsParamsLogged == event.parameters)
    }
    
    @Test
    func test_didAppear_faceID() {
        let vc = GDSScreen(viewModel: sut)
        #expect(mockAnalyticsService.screenViews.count == 0)
        
        let screen = ErrorScreenView(id: ErrorAnalyticsScreenID.allowFaceID.rawValue,
                                     screen: ErrorAnalyticsScreen.allowFaceID,
                                     titleKey: "app_localAuthManagerBiometricsErrorTitle",
                                     variableKeys: ["app_FaceID"])
        
        vc.viewDidAppear(false)
        #expect(mockAnalyticsService.screenViews.count == 1)
        #expect(mockAnalyticsService.screenViews as? [ErrorScreenView] == [screen])
        #expect(mockAnalyticsService.screenParamsLogged == screen.parameters)
    }
    
    @Test
    func test_didAppear_touchID() {
        let sut = LocalAuthBiometricsErrorViewModel(analyticsService: mockAnalyticsService, localAuthType: .touchID) {}
        let vc = GDSScreen(viewModel: sut)
        #expect(mockAnalyticsService.screenViews.count == 0)
        
        let screen = ErrorScreenView(id: ErrorAnalyticsScreenID.allowTouchID.rawValue,
                                     screen: ErrorAnalyticsScreen.allowTouchID,
                                     titleKey: "app_localAuthManagerBiometricsErrorTitle",
                                     variableKeys: ["app_TouchID"])
        
        vc.viewDidAppear(false)
        #expect(mockAnalyticsService.screenViews.count == 1)
        #expect(mockAnalyticsService.screenViews as? [ErrorScreenView] == [screen])
        #expect(mockAnalyticsService.screenParamsLogged == screen.parameters)
    }
    
    @Test
    func test_didDismiss() {
        #expect(mockAnalyticsService.eventsLogged.count == 0)

        sut.didDismiss?.perform()
        let event = IconEvent(textKey: "cancel")
        
        #expect(mockAnalyticsService.eventsLogged.count == 1)
        #expect(mockAnalyticsService.eventsLogged == [event.name.name])
        #expect(mockAnalyticsService.eventsParamsLogged == event.parameters)
    }
}
