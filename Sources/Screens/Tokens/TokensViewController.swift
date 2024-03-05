import Authentication
import GDSCommon
import UIKit

class TokensViewController: UIViewController {
    override var nibName: String? { "TokensView" }
    
    private let tokens: TokenResponse
    
    init(tokens: TokenResponse) {
        self.tokens = tokens
        super.init(nibName: "TokensView", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBOutlet private var loggedInLabel: UILabel! {
        didSet {
            let string = NSMutableAttributedString(key: "Logged in ")
            let image = NSTextAttachment(image: UIImage(systemName: "checkmark.circle.fill")!)
            let imageString = NSAttributedString(attachment: image)
            string.append(imageString)
            string.addAttribute(.foregroundColor, value: UIColor.gdsGreen, range: NSRange(location: 10, length: 1))
            loggedInLabel.attributedText = string
            loggedInLabel.accessibilityIdentifier = "logged-in-title"
        }
    }
    
    @IBOutlet private var accessTokenLabel: UILabel! {
        didSet {
            accessTokenLabel.attributedText = GDSLocalisedString(stringLiteral: "Access Token: \(tokens.accessToken)",
                                                                 attributes: [("Access Token:", [.font: UIFont.bodyBold])]).attributedValue
            accessTokenLabel.accessibilityIdentifier = "access-token"
        }
    }
    
    @IBOutlet private var idTokenLabel: UILabel! {
        didSet {
            idTokenLabel.attributedText = GDSLocalisedString(stringLiteral: "ID Token: \(tokens.idToken)",
                                                             attributes: [("ID Token:", [.font: UIFont.bodyBold])]).attributedValue
            idTokenLabel.accessibilityIdentifier = "id-token"
        }
    }
    
    @IBOutlet private var refreshTokenLabel: UILabel! {
        didSet {
            if let refreshToken = tokens.refreshToken {
                refreshTokenLabel.attributedText = GDSLocalisedString(stringLiteral: "Refresh Token: \(refreshToken)",
                                                                      attributes: [("Refresh Token:", [.font: UIFont.bodyBold])]).attributedValue
                refreshTokenLabel.accessibilityIdentifier = "refresh-token"
            } else {
                refreshTokenLabel.isHidden = true
            }
        }
    }
}
