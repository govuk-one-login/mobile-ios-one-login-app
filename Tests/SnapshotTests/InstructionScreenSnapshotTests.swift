import DesignSystem
import LocalAuthenticationWrapper
@testable import OneLogin
import Testing
import UIKit

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
        let vc = GDSScreen(viewModel: sut)
        
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
        let vc = GDSScreen(viewModel: sut)
        
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
        let vc = GDSScreen(viewModel: sut)
        
        vc.assertSnapshot()
    }
    
    @Test
    func test_oneLoginIntroScreen() {
        let sut = OneLoginIntroViewModel(analyticsService: analyticsService) { nil }
        let vc = GDSScreen(viewModel: sut)
        
        vc.assertSnapshot()
    }
    
    @Test
    func test_loadingScreen() {
        let sut = LoadingViewModel(analyticsService: analyticsService)
        let vc = GDSScreen(viewModel: sut)
        
        vc.assertSnapshot()
    }
    
    @Test
    func test_signOutSuccessfulScreen() {
        let sut = SignOutSuccessfulViewModel(buttonAction: {})
        let vc = GDSScreen(viewModel: sut)
        
        vc.assertSnapshot()
    }
    
    @Test
    func test_signOutScreen() {
        let root = UINavigationController()
        let sut = SignOutConfirmationViewModel(
            analyticsService: analyticsService,
            action: {}
        )
        let vc = GDSScreen(viewModel: sut)
        root.pushViewController(vc, animated: true)
        root.assertSnapshot()
    }
    
    @Test
    func test_signInWarningScreen() {
        let root = UINavigationController()
        let sut = SignInAgainViewModel(
            analyticsService: analyticsService,
            action: { nil }
        )
        let vc = GDSScreen(viewModel: sut)
        root.pushViewController(vc, animated: true)
        root.assertSnapshot()
    }
    
    @Test
    func test_settingsScreen() {
        let root = UINavigationController()
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
        
        root.pushViewController(vc, animated: true)
        root.assertSnapshot()
    }
    
    @Test
    func test_homeScreen() {
        let vc = HomeViewController(analyticsService: analyticsService,
                                    criOrchestrator: MockCRIOrchestrator())
        
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
