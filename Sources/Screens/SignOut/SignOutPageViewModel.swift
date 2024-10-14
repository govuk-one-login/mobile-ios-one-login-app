import GDSAnalytics
import GDSCommon
import Logging
import UIKit

struct SignOutPageViewModel: GDSInstructionsViewModel, BaseViewModel {
    let title: GDSLocalisedString = "app_signOutConfirmationTitleNoWallet"
    let body: String = GDSLocalisedString(stringLiteral: "app_signOutConfirmationBody1NoWallet").value
    var childView = UIView()
    let buttonViewModel: any ButtonViewModel
    let secondaryButtonViewModel: (any ButtonViewModel)? = nil
    let analyticsService: AnalyticsService
    
    let rightBarButtonTitle: GDSLocalisedString? = "app_cancelButton"
    let backButtonIsHidden: Bool = true
    
    init(analyticsService: AnalyticsService,
         buttonAction: @escaping () -> Void) {
        self.analyticsService = analyticsService
        self.buttonViewModel = AnalyticsButtonViewModel(titleKey: "app_signOutAndDeletePreferences",
                                                        backgroundColor: .gdsGreen,
                                                        analyticsService: analyticsService) {
            buttonAction()
        }
        self.childView = configureStackView()
    }
    
    func didAppear() {
        let screen = ScreenView(id: ProfileAnalyticsScreenID.signOutScreenNoWallet.rawValue,
                                screen: ProfileAnalyticsScreen.signOutScreenNoWallet,
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
                                                    GDSLocalisedString(stringLiteral: "app_signOutConfirmationBullet1iOSNoWallet").value,
                                                    GDSLocalisedString(stringLiteral: "app_signOutConfirmationBullet2NoWallet").value
                                                ])
        bulletView.accessibilityIdentifier = "sign-out-bullet-list-no-wallet"
        
        let body2Label = {
            let label = UILabel()
            label.text = GDSLocalisedString(stringLiteral: "app_signOutConfirmationBody2NoWallet").value
            label.adjustsFontForContentSizeCategory = true
            label.numberOfLines = 0
            label.font = .bodyBold
            label.accessibilityIdentifier = "sign-out-body2-text-no-wallet"
            return label
        }()
        
        let stackView = UIStackView(arrangedSubviews: [bulletView, body2Label])
        stackView.axis = .vertical
        stackView.alignment = .top
        stackView.spacing = 12
        stackView.accessibilityIdentifier = "sign-out-stack-view-no-wallet"
        return stackView
    }
}
