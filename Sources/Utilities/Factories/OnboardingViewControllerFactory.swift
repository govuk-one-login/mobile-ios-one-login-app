import Authentication
import GDSCommon
import Logging

@MainActor
final class OnboardingViewControllerFactory {
    static func createUnlockScreen(analyticsService: AnalyticsService,
                                   primaryButtonAction: @escaping () -> Void) -> UnlockScreenViewController {
        let viewModel = UnlockScreenViewModel(analyticsService: analyticsService) {
            primaryButtonAction()
        }
        return UnlockScreenViewController(viewModel: viewModel)
    }
    
    static func createIntroViewController(analyticsService: AnalyticsService,
                                          action: @escaping () -> Void) -> IntroViewController {
        let viewModel = OneLoginIntroViewModel(analyticsService: analyticsService) {
            action()
        }
        return IntroViewController(viewModel: viewModel)
    }
    
    static func createAnalyticsPeferenceScreen(primaryButtonAction: @escaping () -> Void,
                                               secondaryButtonAction: @escaping () -> Void,
                                               textButtonAction: @escaping () -> Void) -> ModalInfoViewController {
        let viewModel = AnalyticsPreferenceViewModel {
            primaryButtonAction()
        } secondaryButtonAction: {
            secondaryButtonAction()
        } textButtonAction: {
            textButtonAction()
        }
        return ModalInfoViewController(viewModel: viewModel)
    }
    
    static func createPasscodeInformationScreen(analyticsService: AnalyticsService,
                                                action: @escaping () -> Void) -> GDSInformationViewController {
        let viewModel = PasscodeInformationViewModel(analyticsService: analyticsService) {
            action()
        }
        return GDSInformationViewController(viewModel: viewModel)
    }
    
    static func createFaceIDEnrollmentScreen(analyticsService: AnalyticsService,
                                             primaryButtonAction: @escaping () -> Void,
                                             secondaryButtonAction: @escaping () -> Void) -> GDSInformationViewController {
        let viewModel = FaceIDEnrollmentViewModel(analyticsService: analyticsService) {
            primaryButtonAction()
        } secondaryButtonAction: {
            secondaryButtonAction()
        }
        return GDSInformationViewController(viewModel: viewModel)
    }
    
    static func createTouchIDEnrollmentScreen(analyticsService: AnalyticsService,
                                              primaryButtonAction: @escaping () -> Void,
                                              secondaryButtonAction: @escaping () -> Void) -> GDSInformationViewController {
        let viewModel = TouchIDEnrollmentViewModel(analyticsService: analyticsService) {
            primaryButtonAction()
        } secondaryButtonAction: {
            secondaryButtonAction()
        }
        return GDSInformationViewController(viewModel: viewModel)
    }
}
