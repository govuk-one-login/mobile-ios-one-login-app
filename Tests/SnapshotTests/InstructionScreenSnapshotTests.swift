import GDSCommon
import LocalAuthenticationWrapper
@testable import OneLogin
import Testing

@MainActor
struct InstructionScreenSnapshotTests {
    let analyticsService = MockAnalyticsService()
    
    @Test
    func test_analyticsPeferenceScreen() {
        let sut = AnalyticsPreferenceViewModel(
            primaryButtonAction: {},
            secondaryButtonAction: {},
            textButtonAction: {}
        )
        let vc = ModalInfoViewController(viewModel: sut)
        
        vc.assertSnapshot()
    }
    
    @Test
    func test_biometricsEnrolmentScreen_touchID() {
        let sut = BiometricsEnrolmentViewModel(
            analyticsService: analyticsService,
            biometricsType: .touchID,
            primaryButtonAction: {},
            secondaryButtonAction: {}
        )
        let vc = GDSCentreAlignedScreen(viewModel: sut)
        
        vc.assertSnapshot()
    }
    
    @Test
    func test_biometricsEnrolmentScreen_faceID() {
        let sut = BiometricsEnrolmentViewModel(
            analyticsService: analyticsService,
            biometricsType: .faceID,
            primaryButtonAction: {},
            secondaryButtonAction: {}
        )
        let vc = GDSCentreAlignedScreen(viewModel: sut)
        
        vc.assertSnapshot()
    }
    
    @Test
    func test_oneLoginIntroScreen() {
        let sut = OneLoginIntroViewModel(
            analyticsService: analyticsService,
            signinAction: {}
        )
        let vc = IntroViewController(viewModel: sut)
        
        vc.assertSnapshot()
    }
    
    @Test
    func test_loginLoadingScreen() {
        let sut = LoginLoadingViewModel(analyticsService: analyticsService)
        let vc = GDSLoadingViewController(viewModel: sut)
        
        vc.assertSnapshot()
    }
    
    @Test
    func test_signOutSuccessfulScreen() {
        let sut = SignOutSuccessfulViewModel(buttonAction: {})
        let vc = GDSCentreAlignedScreen(viewModel: sut)
        
        vc.assertSnapshot()
    }
    
    @Test
    func test_signOutScreen() {
        let sut = SignOutSuccessfulViewModel(buttonAction: {})
        let vc = GDSCentreAlignedScreen(viewModel: sut)
        
        vc.assertSnapshot()
    }
    
    @Test
    func test_settingsScreen() {
        let sut = SettingsTabViewModel(
            analyticsService: analyticsService,
            userProvider: MockUserProvider(),
            urlOpener: MockURLOpener(),
            openSignOutPage: {},
            openDeveloperMenu: {}
        )
        let vc = SettingsViewController(
            viewModel: sut,
            userProvider: MockUserProvider(),
            analyticsPreference: analyticsService.analyticsPreferenceStore)
        
        vc.assertSnapshot()
    }
    
    @Test
    func test_unlockScreen() {
        let sut = UnlockScreenViewModel(
            analyticsService: analyticsService,
            primaryButtonAction: {}
        )
        let vc = UnlockScreenViewController(viewModel: sut)
        
        vc.assertSnapshot()
    }
}
