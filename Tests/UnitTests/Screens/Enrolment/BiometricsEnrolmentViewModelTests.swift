@testable import DesignSystem
import GDSAnalytics
import LocalAuthenticationWrapper
@testable import OneLogin
import Testing

@MainActor
struct BiometricsEnrolmentViewModelTests {
    var mockAnalyticsService: MockAnalyticsService!
    var sut: BiometricsEnrolmentViewModel!
    
    init() {
        mockAnalyticsService = MockAnalyticsService()
        sut = BiometricsEnrolmentViewModel(analyticsService: mockAnalyticsService,
                                           biometricsType: .faceID,
                                           primaryButtonAction: {},
                                           secondaryButtonAction: {})
    }
}

extension BiometricsEnrolmentViewModelTests {
    @Test
    func test_faceID_page() {
        let image = sut.body.first as? GDSImageViewModel
        let titleText = sut.body[1] as? GDSTextViewModel
        let list = sut.body[2] as? GDSListViewModel
        let bodyText = sut.body[3] as? GDSTextViewModel
        let primaryButton = sut.movableFooter.first as? GDSButtonViewModel
        
        #expect(image?.imageColour == DesignSystem.Color.Text.primary)
        #expect(image?.contentMode == .scaleAspectFit)
        #expect(image?.imageFixedHeight == 64)
        #expect(titleText?.title.stringKey == "app_enableBiometricsTitle")
        #expect(titleText?.title.variableKeys == ["app_FaceID"])
        #expect(titleText?.title.value == "Allow Face ID")
        #expect(list?.title?.stringKey == "app_enableBiometricsBody1")
        #expect(list?.title?.variableKeys == ["app_FaceID"])
        #expect(list?.titleConfig?.font == .body)
        #expect(list?.titleConfig?.isHeader == true)
        #expect(list?.items.count == 2)
        #expect(list?.items[0].stringKey == "app_enableBiometricsBullet1")
        #expect(list?.items[1].stringKey == "app_enableBiometricsBullet2")
        #expect(list?.style == .bulleted)
        #expect(bodyText?.title.stringKey == "app_enableBiometricsFaceIDBody2")
        #expect(primaryButton?.title.forState(.normal) == "Allow Face ID")
        #expect(sut.rightBarButtonTitle == nil)
        #expect(sut.backButtonIsHidden)
    }
    
    @Test
    func test_touchID_page() {
        let sut = BiometricsEnrolmentViewModel(analyticsService: mockAnalyticsService,
                                               biometricsType: .touchID,
                                               primaryButtonAction: {},
                                               secondaryButtonAction: {})
        
        let image = sut.body.first as? GDSImageViewModel
        let titleText = sut.body[1] as? GDSTextViewModel
        let list = sut.body[2] as? GDSListViewModel
        let bodyText = sut.body[3] as? GDSTextViewModel
        let primaryButton = sut.movableFooter.first as? GDSButtonViewModel
        
        #expect(image?.imageColour == DesignSystem.Color.Text.primary)
        #expect(image?.contentMode == .scaleAspectFit)
        #expect(image?.imageFixedHeight == 64)
        #expect(titleText?.title.stringKey == "app_enableBiometricsTitle")
        #expect(titleText?.title.variableKeys == ["app_TouchID"])
        #expect(titleText?.title.value == "Allow Touch ID")
        #expect(list?.title?.stringKey == "app_enableBiometricsBody1")
        #expect(list?.title?.variableKeys == ["app_TouchID"])
        #expect(list?.titleConfig?.font == .body)
        #expect(list?.titleConfig?.isHeader == true)
        #expect(list?.items.count == 2)
        #expect(list?.items[0].stringKey == "app_enableBiometricsBullet1")
        #expect(list?.items[1].stringKey == "app_enableBiometricsBullet2")
        #expect(list?.style == .bulleted)
        #expect(bodyText?.title.stringKey == "app_enableBiometricsTouchIDBody2")
        #expect(primaryButton?.title.forState(.normal) == "Allow Touch ID")
        #expect(sut.rightBarButtonTitle == nil)
        #expect(sut.backButtonIsHidden)
    }
    
    @Test
    func test_primaryButton() async {
        var didCallPrimaryButtonAction = false
        
        let sut = BiometricsEnrolmentViewModel(analyticsService: mockAnalyticsService,
                                               biometricsType: .touchID,
                                               primaryButtonAction: { didCallPrimaryButtonAction = true },
                                               secondaryButtonAction: {})

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
    func test_secondaryButton() {
        var didCallSecondaryButtonAction = false
        
        let sut = BiometricsEnrolmentViewModel(analyticsService: mockAnalyticsService,
                                               biometricsType: .touchID,
                                               primaryButtonAction: {},
                                               secondaryButtonAction: { didCallSecondaryButtonAction = true })

        let secondaryButton = sut.movableFooter[1] as? GDSButtonViewModel
        
        #expect(secondaryButton?.title.forState(.normal) == "Skip")
        #expect(!didCallSecondaryButtonAction)
        #expect(mockAnalyticsService.eventsLogged.count == 0)
        secondaryButton?.buttonAction.perform()
        #expect(didCallSecondaryButtonAction)
        #expect(mockAnalyticsService.eventsLogged.count == 1)
        let event = ButtonEvent(textKey: "app_skipButton")
        #expect(mockAnalyticsService.eventsLogged == [event.name.name])
        #expect(mockAnalyticsService.eventsParamsLogged == event.parameters)
    }
    
    @Test
    func test_didAppear_faceID() {
        let sut = BiometricsEnrolmentViewModel(analyticsService: mockAnalyticsService,
                                               biometricsType: .faceID,
                                               primaryButtonAction: {},
                                               secondaryButtonAction: {})
        let vc = GDSScreen(viewModel: sut)
        
        #expect(sut.didDismiss == nil)
        #expect(mockAnalyticsService.screenViews.count == 0)
        vc.viewDidAppear(false)
        #expect(mockAnalyticsService.screenViews.count == 1)
        let screen = ScreenView(id: BiometricEnrolmentAnalyticsScreenID.faceIDEnrolment.rawValue,
                                screen: BiometricEnrolmentAnalyticsScreen.faceIDEnrolment,
                                titleKey: "app_enableBiometricsTitle",
                                variableKeys: ["app_FaceID"])
        #expect(mockAnalyticsService.screenViews as? [ScreenView] == [screen])
        #expect(mockAnalyticsService.screenParamsLogged == screen.parameters)
    }
    
    @Test
    func test_didAppear_touchID() {
        let sut = BiometricsEnrolmentViewModel(analyticsService: mockAnalyticsService,
                                               biometricsType: .touchID,
                                               primaryButtonAction: {},
                                               secondaryButtonAction: {})
        let vc = GDSScreen(viewModel: sut)
        
        #expect(sut.didDismiss == nil)
        #expect(mockAnalyticsService.screenViews.count == 0)
        vc.viewDidAppear(false)
        #expect(mockAnalyticsService.screenViews.count == 1)
        let screen = ScreenView(id: BiometricEnrolmentAnalyticsScreenID.touchIDEnrolment.rawValue,
                                screen: BiometricEnrolmentAnalyticsScreen.touchIDEnrolment,
                                titleKey: "app_enableBiometricsTitle",
                                variableKeys: ["app_TouchID"])
        #expect(mockAnalyticsService.screenViews as? [ScreenView] == [screen])
        #expect(mockAnalyticsService.screenParamsLogged == screen.parameters)
    }
}
