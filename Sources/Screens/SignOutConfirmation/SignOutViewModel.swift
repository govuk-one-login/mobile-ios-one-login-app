import GDSCommon
import Logging
import UIKit

struct SignOutPageViewModel: GDSInstructionsViewModel, BaseViewModel {
    let title: GDSLocalisedString = "app_signOutConfirmationTitle"
    let body: String = GDSLocalisedString(stringLiteral: "app_signOutConfirmationBody1").value
    var childView = UIView()
    let buttonViewModel: ButtonViewModel
    let rightBarButtonTitle: GDSLocalisedString? = "app_cancelButton"
    
    let secondaryButtonViewModel: (any ButtonViewModel)? = nil
    let backButtonIsHidden: Bool = true
    let analyticsService: AnalyticsService

    init(analyticsService: AnalyticsService,
         buttonAction: @escaping () -> Void) {
        self.analyticsService = analyticsService
        self.buttonViewModel = AnalyticsButtonViewModel(titleKey: "app_signOutAndDeleteAppDataButton",
                                                        backgroundColor: .gdsRed,
                                                        analyticsService: analyticsService) {
            buttonAction()
        }
        self.childView = configureStackView()

    }

    func didAppear() {

    }

    func didDismiss() {

    }

    private func configureStackView() -> UIView {
        let body2Label = UILabel()
        body2Label.accessibilityIdentifier = "sign-out-body2-text"
        let body3Label = UILabel()
        body2Label.accessibilityIdentifier = "sign-out-body3-text"
        let bulletView: BulletView = BulletView(title: "",
                                                text: [
                                                 GDSLocalisedString(stringLiteral: "app_signOutConfirmationBullet1").value,
                                                 GDSLocalisedString(stringLiteral: "app_signOutConfirmationBullet2").value,
                                                 GDSLocalisedString(stringLiteral: "app_signOutConfirmationBullet3").value
                                                ])
        bulletView.accessibilityIdentifier = "sign-out-bullet-list"
        body2Label.text = GDSLocalisedString(stringLiteral: "app_signOutConfirmationBody2").value
        body2Label.numberOfLines = 0
        body2Label.font = .bodyBold
        body3Label.text = GDSLocalisedString(stringLiteral: "app_signOutConfirmationBody3").value
        body3Label.numberOfLines = 0

        let stackView = UIStackView(arrangedSubviews: [bulletView, body2Label, body3Label])
        stackView.axis = .vertical
        stackView.alignment = .top
        stackView.spacing = 12
        stackView.accessibilityIdentifier = "sign-out-stack-view"

        return stackView
    }
}
