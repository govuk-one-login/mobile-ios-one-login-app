import DesignSystem
import GDSAnalytics
import GDSCommon
import Logging
import UIKit

struct SignOutPageViewModel: GDSInstructionsViewModel, BaseViewModel {
    let title: GDSCommon.GDSLocalisedString = "app_signOutConfirmationTitle"
    let body: String = GDSCommon.GDSLocalisedString(stringLiteral: "app_signOutConfirmationBody1").value
    var childView = UIView()
    let buttonViewModel: any ButtonViewModel
    let secondaryButtonViewModel: (any ButtonViewModel)? = nil
    let analyticsService: OneLoginAnalyticsService
    
    let rightBarButtonTitle: GDSCommon.GDSLocalisedString? = "app_cancelButton"
    let backButtonIsHidden: Bool = true
    
    init(analyticsService: OneLoginAnalyticsService,
         buttonAction: @escaping () -> Void) {
        self.analyticsService = analyticsService.addingAdditionalParameters([
            OLTaxonomyKey.level2: OLTaxonomyValue.settings,
            OLTaxonomyKey.level3: OLTaxonomyValue.signout
        ])
        self.buttonViewModel = AnalyticsButtonViewModel(titleKey: "app_signOutAndDeleteAppDataButton",
                                                        backgroundColor: DesignSystem.Color.Base.red1,
                                                        analyticsService: analyticsService) {
            buttonAction()
        }
        self.childView = configureStackView()
    }
    
    func didAppear() {
        let screen = ScreenView(id: SettingsAnalyticsScreenID.signOutScreenWithWallet.rawValue,
                                screen: SettingsAnalyticsScreen.signOutScreenWithWallet,
                                titleKey: title.stringKey)
        analyticsService.trackScreen(screen)
    }
    
    func didDismiss() {
        let event = ButtonEvent(textKey: "back")
        analyticsService.logEvent(event)
    }
    
    private func configureStackView() -> UIView {
        let body2Label = {
            let label = UILabel()
            label.text = GDSCommon.GDSLocalisedString(stringLiteral: "app_signOutConfirmationBody2").value
            label.adjustsFontForContentSizeCategory = true
            label.numberOfLines = 0
            label.font = .body
            label.accessibilityIdentifier = "sign-out-body2-text-with-wallet"
            return label
        }()
        
        let bulletView: BulletView = BulletView(title: nil,
                                                text: [
                                                    GDSCommon.GDSLocalisedString(stringKey: "app_signOutConfirmationBullet1",
                                                                       "app_walletString").value,
                                                    GDSCommon.GDSLocalisedString(stringLiteral: "app_signOutConfirmationBullet2").value,
                                                    GDSCommon.GDSLocalisedString(stringLiteral: "app_signOutConfirmationBullet3").value
                                                ])
        bulletView.accessibilityIdentifier = "sign-out-bullet-list-with-wallet"
        
        let body3Label = {
            let label = UILabel()
            label.text = GDSCommon.GDSLocalisedString(stringKey: "app_signOutConfirmationBody3",
                                            "app_walletString").value
            label.adjustsFontForContentSizeCategory = true
            label.numberOfLines = 0
            label.font = .body
            label.accessibilityIdentifier = "sign-out-body3-text-with-wallet"
            return label
        }()
        
        let stackView = UIStackView(arrangedSubviews: [body2Label, bulletView, body3Label])
        stackView.axis = .vertical
        stackView.alignment = .top
        stackView.spacing = 12
        stackView.accessibilityIdentifier = "sign-out-stack-view-with-wallet"
        return stackView
    }
}
