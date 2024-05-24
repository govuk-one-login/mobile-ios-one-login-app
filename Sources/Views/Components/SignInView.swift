import GDSCommon
import UIKit

final class SignInView: NibView {
    var userEmail: String? {
        didSet {
            emailLabel.attributedText = attributedEmailString
        }
    }
    
    init() {
        super.init(forcedNibName: "SignInView", bundle: nil)
    }
    
    @available(*, unavailable, renamed: "init()")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBOutlet private var emailLabel: UILabel! {
        didSet {
            emailLabel.accessibilityIdentifier = "signin-view-email-label"
        }
    }
    
    private var attributedEmailString: NSAttributedString? {
        guard let userEmail else { return nil }
        return GDSLocalisedString(stringKey: "app_displayEmail",
                                  userEmail,
                                  attributes: [(userEmail, [.font: UIFont.bodyBold])]).attributedValue
    }
}
