import Authentication
import GDSCommon
import MobilePlatformServices
import Networking
import SecureStore
import UIKit

final class DeveloperMenuViewController: BaseViewController {
    override var nibName: String? { "DeveloperMenu" }

    private let viewModel: DeveloperMenuViewModel
    private let sessionManager: SessionManager
    private let helloWorldProvider: HelloWorldProvider

    private let defaultsStore: DefaultsStorable

    init(viewModel: DeveloperMenuViewModel,
         sessionManager: SessionManager,
         helloWorldProvider: HelloWorldProvider,
         defaultsStore: DefaultsStorable = UserDefaults.standard) {
        self.viewModel = viewModel
        self.sessionManager = sessionManager
        self.helloWorldProvider = helloWorldProvider
        self.defaultsStore = defaultsStore
        super.init(viewModel: viewModel,
                   nibName: "DeveloperMenu",
                   bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBOutlet private var happyPathButton: RoundedButton! {
        didSet {
            happyPathButton.titleLabel?.adjustsFontForContentSizeCategory = true
            happyPathButton.setTitle("Hello World Happy", for: .normal)
            happyPathButton.accessibilityIdentifier = "sts-happy-path-button"
        }
    }
    
    @IBAction private func happyPathButtonAction(_ sender: Any) {
        happyPathButton.isLoading = true
        helloWorldHappyPath()
    }
    
    // Makes a successful request to the hello-world endpoint as long as the access token is valid
    private func helloWorldHappyPath() {
        Task {
            do {
                let message = try await helloWorldProvider.requestHelloWorld()
                happyPathResultLabel.showSuccessMessage(message)
            } catch let error as ServerError {
                happyPathResultLabel.showErrorMessage(error)
            } catch {
                happyPathResultLabel.showErrorMessage()
            }
            happyPathButton.isLoading = false
        }
    }
    
    @IBOutlet private var happyPathResultLabel: UILabel! {
        didSet {
            happyPathResultLabel.font = .bodyBold
            happyPathResultLabel.isHidden = true
            happyPathResultLabel.accessibilityIdentifier = "sts-happy-path-result"
        }
    }
    
    @IBOutlet private var errorPathButton: RoundedButton! {
        didSet {
            errorPathButton.titleLabel?.adjustsFontForContentSizeCategory = true
            errorPathButton.setTitle("Hello World Error", for: .normal)
            errorPathButton.accessibilityIdentifier = "sts-error-path-button"
        }
    }
    
    @IBAction private func errorPathButtonAction(_ sender: Any) {
        errorPathButton.isLoading = true
        helloWorldErrorPath()
    }
    
    // Makes an unsuccessful request to the hello-world endpoint, the scope is invalid for this so a 400 response is returned
    private func helloWorldErrorPath() {
        Task {
            do {
                _ = try await helloWorldProvider.requestHelloWorldWrongScope()
            } catch let error as ServerError {
                errorPathResultLabel.showErrorMessage(error)
            } catch {
                errorPathResultLabel.showErrorMessage()
            }
            errorPathButton.isLoading = false
        }
    }
    
    @IBOutlet private var errorPathResultLabel: UILabel! {
        didSet {
            errorPathResultLabel.isHidden = true
            errorPathResultLabel.accessibilityIdentifier = "sts-error-path-result"
            errorPathResultLabel.font = .bodyBold
        }
    }
    
    @IBOutlet private var unauthorizedPathButton: RoundedButton! {
        didSet {
            unauthorizedPathButton.titleLabel?.adjustsFontForContentSizeCategory = true
            unauthorizedPathButton.setTitle("Hello World Unauthorized", for: .normal)
            unauthorizedPathButton.accessibilityIdentifier = "sts-unauthorized-path-button"
        }
    }
    
    @IBAction private func unauthorizedPathButtonAction(_ sender: Any) {
        unauthorizedPathButton.isLoading = true
        helloWorldUnauthorizedPath()
    }
    
    // Makes an unsuccessful request to the hello-world endpoint, the endpoint returns a 401 unauthorized response
    private func helloWorldUnauthorizedPath() {
        Task {
            do {
                _ = try await helloWorldProvider.requestHelloWorldWrongEndpoint()
            } catch let error as ServerError {
                unauthorizedPathResultLabel.showErrorMessage(error)
            } catch {
                unauthorizedPathResultLabel.showErrorMessage()
            }
            unauthorizedPathButton.isLoading = false
        }
    }
    
    @IBOutlet private var unauthorizedPathResultLabel: UILabel! {
        didSet {
            unauthorizedPathResultLabel.isHidden = true
            unauthorizedPathResultLabel.accessibilityIdentifier = "sts-unauthorized-path-result"
            unauthorizedPathResultLabel.font = .bodyBold
        }
    }
    
    @IBOutlet private var deletePersistentSessionIDButton: RoundedButton! {
        didSet {
            deletePersistentSessionIDButton.titleLabel?.adjustsFontForContentSizeCategory = true
            deletePersistentSessionIDButton.setTitle("Delete Persistent Session ID", for: .normal)
            deletePersistentSessionIDButton.accessibilityIdentifier = "sts-delete-persistent-session-id-path-button"
        }
    }
    
    @IBAction private func deletePersistentSessionIDAction(_ sender: Any) {
        let encryptedConfiguration = SecureStorageConfiguration(
            id: OLString.persistentSessionID,
            accessControlLevel: .open
        )
        let persistentSessionStore = SecureStoreService(configuration: encryptedConfiguration)
        persistentSessionStore.deleteItem(itemName: OLString.persistentSessionID)
        deletePersistentSessionIDButton.backgroundColor = .gdsBrightPurple
    }
    
    @IBOutlet private var expireAccessTokenButton: RoundedButton! {
        didSet {
            expireAccessTokenButton.titleLabel?.adjustsFontForContentSizeCategory = true
            expireAccessTokenButton.setTitle("Expire Access Token", for: .normal)
            expireAccessTokenButton.accessibilityIdentifier = "sts-expire-access-token-button"
        }
    }
    
    @IBAction private func expireAccessTokenAction(_ sender: Any) {
        // swiftlint:disable line_length
        let expiredToken = """
        eyJhbGciOiJFUzI1NiIsInR5cCI6ImF0K0pXVCIsImtpZCI6IjE2ZGI2NTg3LTU0NDUtNDVkNi1hN2Q5LTk4NzgxZWJkZjkzZCJ9.eyJpc3MiOiJodHRwczovL3Rva2VuLmJ1aWxkLmFjY291bnQuZ292LnVrIiwic3ViIjoiMDc5NGJmZWMtZjg0Yy00NzI2LWI5MzYtZDEyZTZhNDU2Y2I4IiwiYXVkIjoiaHR0cHM6Ly90b2tlbi5idWlsZC5hY2NvdW50Lmdvdi51ayIsIm5vbmNlIjoiXy1GN0RxZkVDUWR4QWR5eVdwLXV3VFFPcTRRcEM5TzFfamtkVFBuaVEyRSIsImlhdCI6MTcyNTAzMjcwMiwiZXhwIjoxNzI1MDM0NTAyfQ.bIfKSKu3HG5F50fTVw1FR9Xqxc5EjwCFZ3efj24mOaKH4kBDWfTI7rrJAXZi6158oU02xPU6gqNJOYzhXHYKDQ
        """
        // swiftlint:enable line_length
        sessionManager.tokenProvider.update(subjectToken: expiredToken)
        UserDefaults.standard.set(Date.distantPast, forKey: OLString.accessTokenExpiry)
        expireAccessTokenButton.backgroundColor = .gdsBrightPurple
    }
}

fileprivate extension UILabel {
    func showErrorMessage(_ error: ServerError? = nil) {
        textColor = .red
        isHidden = false
        if let error {
            text = "Error code: \(error.errorCode)\nEndpoint: \(error.endpoint ?? "missing")"
        } else {
            text = "Error"
        }
    }
    
    func showSuccessMessage(_ message: String) {
        textColor = .gdsGreen
        isHidden = false
        text = message
    }
}
