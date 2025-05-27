import GDSAnalytics
import GDSCommon
import LocalAuthenticationWrapper
import Logging
import UIKit

struct BiometricsEnrolmentViewModel: GDSCentreAlignedViewModel,
                                     GDSCentreAlignedViewModelWithImage,
                                     GDSCentreAlignedViewModelWithPrimaryButton,
                                     GDSCentreAlignedViewModelWithSecondaryButton,
                                     GDSCentreAlignedViewModelWithChildView,
                                     BaseViewModel {
    let image: String
    let imageWeight: UIFont.Weight? = .thin
    let imageColour: UIColor? = nil
    let imageHeightConstraint: CGFloat? = 64
    let title: GDSLocalisedString
    var body: GDSLocalisedString?
    let primaryButtonViewModel: ButtonViewModel
    let secondaryButtonViewModel: ButtonViewModel
    let analyticsService: OneLoginAnalyticsService
    let isFaceID: Bool
    let enrolmentJourney: EnrolmentJourney
    let biometricsTypeString: String
    var childView: UIView = UIView()
    
    let rightBarButtonTitle: GDSLocalisedString? = nil
    let backButtonIsHidden: Bool = true
    
    init(analyticsService: OneLoginAnalyticsService,
         biometricsType: LocalAuthType,
         enrolmentJourney: EnrolmentJourney,
         primaryButtonAction: @escaping () -> Void,
         secondaryButtonAction: @escaping () -> Void) {
        self.analyticsService = analyticsService
        self.enrolmentJourney = enrolmentJourney
        self.isFaceID = biometricsType == .faceID
        self.biometricsTypeString = isFaceID ? "app_FaceID" : "app_TouchID"
        self.image = isFaceID ? "faceid" : "touchid"
        self.primaryButtonViewModel = AnalyticsButtonViewModel(titleKey: "app_enableBiometricsButton",
                                                               biometricsTypeString,
                                                               analyticsService: analyticsService) {
            primaryButtonAction()
        }
        self.secondaryButtonViewModel = AnalyticsButtonViewModel(titleKey: "app_skipButton",
                                                                 analyticsService: analyticsService) {
            secondaryButtonAction()
        }
        
        if enrolmentJourney == .wallet {
            self.title = GDSLocalisedString(stringKey: "app_enableBiometricsTitle", biometricsTypeString)
            self.childView = configureWalletEnrolmentView()
        } else {
            self.title = GDSLocalisedString(stringKey: "app_enableLoginBiometricsTitle", biometricsTypeString)
            self.body = isFaceID ?
            GDSLocalisedString(stringKey: "app_enableFaceIDBody", "app_nameString") :
            GDSLocalisedString(stringKey: "app_enableTouchIDBody", "app_nameString")
        }
    }
    
    private func configureWalletEnrolmentView() -> UIView {
        let bulletView: BulletView = BulletView(title: GDSLocalisedString(stringKey: "app_enableBiometricsBody1",
                                                                          biometricsTypeString).value,
                                                text: [
                                                    GDSLocalisedString(stringLiteral: "app_enableBiometricsBullet1").value,
                                                    GDSLocalisedString(stringLiteral: "app_enableBiometricsBullet2").value
                                                ],
                                                titleFont: .body)
        bulletView.accessibilityIdentifier = "biometrics-enrolment-bullet-list"
        
        let body2Text = isFaceID ? "app_enableBiometricsFaceIDBody2" : "app_enableBiometricsTouchIDBody2"
        let body2Label = {
            let label = UILabel()
            label.text = GDSLocalisedString(stringLiteral: body2Text).value
            label.adjustsFontForContentSizeCategory = true
            label.numberOfLines = 0
            label.font = .body
            label.textAlignment = .center
            label.accessibilityIdentifier = "biometrics-enrolment-body2-text"
            return label
        }()
        
        let stackView = UIStackView(arrangedSubviews: [bulletView, body2Label])
        stackView.axis = .vertical
        stackView.alignment = .top
        stackView.spacing = 12
        stackView.accessibilityIdentifier = "biometrics-enrolment-stack-view"
        
        return stackView
    }
    
    func didAppear() {
        let id = switch enrolmentJourney {
        case .login:
            isFaceID ?
            BiometricEnrolmentAnalyticsScreenID.faceIDEnrolment.rawValue :
            BiometricEnrolmentAnalyticsScreenID.touchIDEnrolment.rawValue
        case .wallet:
            isFaceID ?
            BiometricEnrolmentAnalyticsScreenID.faceIDWalletEnrolment.rawValue :
            BiometricEnrolmentAnalyticsScreenID.touchIDWalletEnrolment.rawValue
        }
        
        let screenID = isFaceID ?
        BiometricEnrolmentAnalyticsScreen.faceIDEnrolment :
        BiometricEnrolmentAnalyticsScreen.touchIDEnrolment
        
        let screen = ScreenView(id: id,
                                screen: screenID,
                                titleKey: title.stringKey,
                                variableKeys: [biometricsTypeString])
        analyticsService.trackScreen(screen)
    }
    
    func didDismiss() { /* Conforming to BaseViewModel */ }
}
