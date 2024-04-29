import GDSCommon
import UIKit

class SignInView: NibView {

    var viewModel: SignInViewModel
    init(viewModel: SignInViewModel) {
        self.viewModel = viewModel
        super.init(forcedNibName: "SignInView", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBOutlet private var emailLabel: UILabel! {
        didSet {
            guard let emailLabel else { return }
            emailLabel.attributedText = attributedEmailString
        }
    }
    
    func updateEmail(_ email: String) {
        viewModel.userEmail = email
        emailLabel.attributedText = attributedEmailString
    }
    
    private var attributedEmailString: NSAttributedString? {
        guard let email = viewModel.userEmail else { return nil }
        return GDSLocalisedString(stringKey: "app_displayEmail",
                                  email,
                                  attributes: [(email, [.font: UIFont.bodyBold])]).attributedValue
    }
}
