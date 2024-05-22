import GDSCommon
import UIKit

struct SignOutPage: GDSInstructionsViewModel {
    
    let title: GDSLocalisedString = "app_signOutConfirmationTitle"
    let body: String = GDSLocalisedString(stringLiteral: "app_signOutConfirmationBody2").value
    let childView: UIView = BulletView(title: GDSLocalisedString(stringLiteral: "app_signOutConfirmationBody1").value,
                                       text: [
                                        GDSLocalisedString(stringLiteral: "app_signOutConfirmationBullet1").value,
                                        GDSLocalisedString(stringLiteral: "app_signOutConfirmationBullet2").value,
                                        GDSLocalisedString(stringLiteral: "app_signOutConfirmationBullet3").value
                                       ])
    var label = UILabel()
    let body2: String = GDSLocalisedString(stringLiteral: "app_signOutConfirmationBody2").value
    let body3: String = GDSLocalisedString(stringLiteral: "app_signOutConfirmationBody3").value
    let buttonViewModel: ButtonViewModel
    let secondaryButtonViewModel: (any ButtonViewModel)? = nil

    init(buttonAction: @escaping () -> Void) {
        label.text = "body2 \n\(body3)"
        childView.addSubview(label)
        self.buttonViewModel = StandardButtonViewModel(titleKey: "app_signOutAndDeleteAppDataButton") {
            buttonAction()
        }
    }
}
