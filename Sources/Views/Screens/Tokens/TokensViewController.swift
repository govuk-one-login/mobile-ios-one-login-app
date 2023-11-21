import UIKit

class TokensViewController: UIViewController {
    override var nibName: String? { "TokensView" }

    private var accessToken = "mock_auth_token"
    private var idToken = "mock_id_token"
    private var refreshToken = "mock_refresh_token"

    init() {
        super.init(nibName: "TokensView", bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @IBOutlet weak var loggedInLabel: UILabel! {
        didSet {
            loggedInLabel.text = "Logged in"
            loggedInLabel.accessibilityIdentifier = "logged-in-title"
        }
    }

    @IBOutlet weak var accessTokenLabel: UILabel! {
        didSet {
            accessTokenLabel.text = "Access Token \(accessToken)"
            accessTokenLabel.accessibilityIdentifier = "access-token"
        }
    }

    @IBOutlet weak var idTokenLabel: UILabel! {
        didSet {
            idTokenLabel.text = "ID Token: \(idToken)"
            idTokenLabel.accessibilityIdentifier = "id-token"
        }
    }

    @IBOutlet weak var refreshTokenLabel: UILabel! {
        didSet {
            refreshTokenLabel.text = "Refresh Token: \(refreshToken)"
            refreshTokenLabel.accessibilityIdentifier = "refresh-token"
        }
    }


}
