import GDSAnalytics
import GDSCommon
import LocalAuthenticationWrapper
import Logging
import UIKit

struct BiometricsEnrolmentViewModel: GDSCentreAlignedViewModel,
                                 GDSCentreAlignedViewModelWithImage,
                                 GDSCentreAlignedViewModelWithPrimaryButton,
                                 GDSCentreAlignedViewModelWithSecondaryButton,
                                 BaseViewModel {
    let image: String
    let imageWeight: UIFont.Weight? = .thin
    let imageColour: UIColor? = nil
    let imageHeightConstraint: CGFloat? = 64
    let title: GDSLocalisedString
    let body: GDSLocalisedString?
    let primaryButtonViewModel: ButtonViewModel
    let secondaryButtonViewModel: ButtonViewModel
    let analyticsService: OneLoginAnalyticsService
    let isFaceID: Bool
    let biometricsTypeString: String
    let enrolmentJourney: EnrolmentJourney
    
    let rightBarButtonTitle: GDSLocalisedString? = nil
    let backButtonIsHidden: Bool = true
    
    init(analyticsService: OneLoginAnalyticsService,
         biometricsType: LocalAuthType,
         enrolmentJourney: EnrolmentJourney,
         primaryButtonAction: @escaping () -> Void,
         secondaryButtonAction: @escaping () -> Void) {
        self.analyticsService = analyticsService
        self.isFaceID = biometricsType == .faceID
        self.biometricsTypeString = isFaceID ? "app_FaceID" : "app_TouchID"
        self.enrolmentJourney = enrolmentJourney
        self.image = isFaceID ? "faceid" : "touchid"
        self.title = GDSLocalisedString(stringKey: "app_enableLoginBiometricsTitle", biometricsTypeString)
        self.body = isFaceID ? "app_enableFaceIDBody" : "app_enableTouchIDBody"
        self.primaryButtonViewModel = AnalyticsButtonViewModel(titleKey: GDSLocalisedString(stringKey: "app_enableBiometricsButton",
                                                                                            biometricsTypeString).value,
                                                               analyticsService: analyticsService) {
            primaryButtonAction()
        }
        self.secondaryButtonViewModel = AnalyticsButtonViewModel(titleKey: "app_skipButton",
                                                                 analyticsService: analyticsService) {
            secondaryButtonAction()
        }
    }
    
    func didAppear() {
        let id = isFaceID ? BiometricEnrolmentAnalyticsScreenID.faceIDEnrolment.rawValue : BiometricEnrolmentAnalyticsScreenID.touchIDEnrolment.rawValue
        let screenID = isFaceID ? BiometricEnrolmentAnalyticsScreen.faceIDEnrolment : BiometricEnrolmentAnalyticsScreen.touchIDEnrolment
        let screen = ScreenView(id: id,
                                screen: screenID,
                                titleKey: title.stringKey)
        analyticsService.trackScreen(screen)
    }
    
    func didDismiss() { /* Conforming to BaseViewModel */ }
}
