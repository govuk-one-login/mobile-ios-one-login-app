import GDSAnalytics
import GDSCommon
import Logging
import UIKit

struct SignOutConfirmationWalletViewModel: GDSInstructionsViewModel, BaseViewModel {
    let title: GDSLocalisedString = "app_signOutConfirmationWalletTitle"
    let body: String = GDSLocalisedString(stringLiteral: "app_signOutConfirmationWalletBody1").value
    var childView = UIView()
    let buttonViewModel: any ButtonViewModel
    let secondaryButtonViewModel: (any ButtonViewModel)? = nil
    let analyticsService: AnalyticsService
    
    let rightBarButtonTitle: GDSLocalisedString? = "app_cancelButton"
    let backButtonIsHidden: Bool = true
    
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
        let screen = ScreenView(id: ProfileAnalyticsScreenID.signOutWalletScreen.rawValue,
                                screen: ProfileAnalyticsScreen.signOutWalletScreen,
                                titleKey: title.stringKey)
        analyticsService.trackScreen(screen)
    }
    
    func didDismiss() {
        let event = ButtonEvent(textKey: "back")
        analyticsService.logEvent(event)
    }
    
    private func configureStackView() -> UIView {
        let bulletView: BulletView = BulletView(title: nil,
                                                text: [
                                                    GDSLocalisedString(stringLiteral: "app_signOutConfirmationWalletBullet1").value,
                                                    GDSLocalisedString(stringLiteral: "app_signOutConfirmationWalletBullet2").value,
                                                    GDSLocalisedString(stringLiteral: "app_signOutConfirmationWalletBullet3").value
                                                ])
        bulletView.accessibilityIdentifier = "sign-out-bullet-list"
        
        let body2Label = {
            let label = UILabel()
            label.text = GDSLocalisedString(stringLiteral: "app_signOutConfirmationWalletBody2").value
            label.adjustsFontForContentSizeCategory = true
            label.numberOfLines = 0
            label.font = .bodyBold
            label.accessibilityIdentifier = "sign-out-body2-text"
            return label
        }()
        
        let body3Label = {
            let label = UILabel()
            label.text = GDSLocalisedString(stringLiteral: "app_signOutConfirmationWalletBody3").value
            label.adjustsFontForContentSizeCategory = true
            label.numberOfLines = 0
            label.font = .body
            label.accessibilityIdentifier = "sign-out-body3-text"
            return label
        }()
        
        let stackView = UIStackView(arrangedSubviews: [bulletView, body2Label, body3Label])
        stackView.axis = .vertical
        stackView.alignment = .top
        stackView.spacing = 12
        stackView.accessibilityIdentifier = "sign-out-stack-view"
        return stackView
    }
}
