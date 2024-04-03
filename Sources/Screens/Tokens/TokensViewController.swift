import Authentication
import GDSCommon
import UIKit

class TokensViewController: UIViewController {
    override var nibName: String? { "TokensView" }
    
    private var accessToken: String? {
        didSet {
            guard let accessTokenLabel = accessTokenLabel else { return }
            accessTokenLabel.attributedText = GDSLocalisedString(stringLiteral: "Access Token: \(accessToken ?? "")",
                                                                 attributes: [("Access Token:", [.font: UIFont.title1Bold])]).attributedValue
        }
    }
    
    init() {
        super.init(nibName: "TokensView", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateToken(accessToken: String?) {
        self.accessToken = accessToken
    }
    
    @IBOutlet private var loggedInLabel: UILabel! {
        didSet {
            let string = NSMutableAttributedString(key: "Logged in ")
            let image = NSTextAttachment(image: UIImage(systemName: "checkmark.circle.fill")!)
            let imageString = NSAttributedString(attachment: image)
            string.append(imageString)
            string.addAttribute(.foregroundColor, value: UIColor.gdsGreen, range: NSRange(location: 10, length: 1))
            loggedInLabel.attributedText = string
            loggedInLabel.font = UIFont.largeTitleBold
            loggedInLabel.accessibilityIdentifier = "logged-in-title"
        }
    }
    
    @IBOutlet private var accessTokenLabel: UILabel! {
        didSet {
            accessTokenLabel.attributedText = GDSLocalisedString(stringLiteral: "Access Token: \(accessToken ?? "")",
                                                                 attributes: [("Access Token:", [.font: UIFont.title1Bold])]).attributedValue
            accessTokenLabel.accessibilityIdentifier = "access-token"
        }
    }
}
