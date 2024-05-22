import GDSCommon
import UIKit

struct SignOutPage: GDSInstructionsViewModel, BaseViewModel {
    var rightBarButtonTitle: GDSCommon.GDSLocalisedString?

    var backButtonIsHidden: Bool

    let title: GDSLocalisedString = "app_signOutConfirmationTitle"
    let body: String = GDSLocalisedString(stringLiteral: "app_signOutConfirmationBody2").value
    let childView = UIView()

    var label = UILabel()
    let body2: String = GDSLocalisedString(stringLiteral: "app_signOutConfirmationBody2").value
    let body3: String = GDSLocalisedString(stringLiteral: "app_signOutConfirmationBody3").value
    let bulletView: BulletView = BulletView(title: GDSLocalisedString(stringLiteral: "app_signOutConfirmationBody1").value,
                                            text: [
                                             GDSLocalisedString(stringLiteral: "app_signOutConfirmationBullet1").value,
                                             GDSLocalisedString(stringLiteral: "app_signOutConfirmationBullet2").value,
                                             GDSLocalisedString(stringLiteral: "app_signOutConfirmationBullet3").value
                                            ])
    let buttonViewModel: ButtonViewModel
    let secondaryButtonViewModel: (any ButtonViewModel)? = nil

    init(buttonAction: @escaping () -> Void) {
//        self.childView.translatesAutoresizingMaskIntoConstraints = false
        label.text = "\(body2) \n\(body3)"
        self.childView.addSubview(bulletView)
        self.childView.addSubview(label)
//        NSLayoutConstraint.activate([
//            label.topAnchor.constraint(equalTo: bulletView.bottomAnchor, constant: 10),
//            label.leadingAnchor.constraint(equalTo: childView.leadingAnchor, constant: 10),
//            label.trailingAnchor.constraint(equalTo: childView.trailingAnchor, constant: -10)
//        ])
        self.buttonViewModel = StandardButtonViewModel(titleKey: "app_signOutAndDeleteAppDataButton") {
            buttonAction()
        }
    }

    func didAppear() {
        <#code#>
    }

    func didDismiss() {
        <#code#>
    }

    func addToChildView() {
        self.childView.translatesAutoresizingMaskIntoConstraints = false
        label.text = "body2 \n\(body3)"
        self.childView.addSubview(bulletView)
        self.childView.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: bulletView.bottomAnchor, constant: 10),
            label.leadingAnchor.constraint(equalTo: childView.leadingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: childView.trailingAnchor, constant: -10)
        ])
    }
}
