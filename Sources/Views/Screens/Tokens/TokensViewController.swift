import Authentication
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
            loggedInLabel.text = "Logged in"
            loggedInLabel.accessibilityIdentifier = "logged-in-title"
        }
    }

    @IBOutlet private var accessTokenLabel: UILabel! {
        didSet {
            accessTokenLabel.text = "Access Token: \(tokens.accessToken)"
            accessTokenLabel.accessibilityIdentifier = "access-token"
        }
    }

    @IBOutlet private var idTokenLabel: UILabel! {
        didSet {
            idTokenLabel.text = "ID Token: \(tokens.idToken)"
            idTokenLabel.accessibilityIdentifier = "id-token"
        }
    }

    @IBOutlet private var refreshTokenLabel: UILabel! {
        didSet {
            refreshTokenLabel.text = "Refresh Token: \(tokens.refreshToken)"
            refreshTokenLabel.accessibilityIdentifier = "refresh-token"
        }
    }
}
