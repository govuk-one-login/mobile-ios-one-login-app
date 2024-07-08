import GDSCommon
import Networking
import UIKit

final class DeveloperMenuViewController: BaseViewController {
    override var nibName: String? { "DeveloperMenu" }
    
    weak var parentCoordinator: HomeCoordinator?
    let viewModel: DeveloperMenuViewModel
    let userStore: UserStorable
    let networkClient: NetworkClient
        
    init(parentCoordinator: HomeCoordinator,
         viewModel: DeveloperMenuViewModel,
         userStore: UserStorable,
         networkClient: NetworkClient) {
        self.parentCoordinator = parentCoordinator
        self.viewModel = viewModel
        self.userStore = userStore
        self.networkClient = networkClient
        super.init(viewModel: viewModel,
                   nibName: "DeveloperMenu",
                   bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBOutlet private var happyPathButton: RoundedButton! {
        didSet {
            if AppEnvironment.callingSTSEnabled {
                happyPathButton.titleLabel?.adjustsFontForContentSizeCategory = true
                happyPathButton.setTitle("Hello World Happy", for: .normal)
            } else {
                happyPathButton.isHidden = true
            }
            happyPathButton.accessibilityIdentifier = "sts-happy-path-button"
        }
    }
    
    @IBAction private func happyPathButtonAction(_ sender: Any) {
        happyPathButton.isLoading = true
        helloWorldHappyPath()
    }
    
    // Makes a successful request to the hello-world endpoint as long as the access token is valid
    private func helloWorldHappyPath() {
        if userStore.validAuthenticatedUser || TokenHolder.shared.validAccessToken {
            Task {
                do {
                    let data = try await networkClient.makeAuthorizedRequest(exchangeRequest: URLRequest(url: AppEnvironment.stsToken),
                                                                             scope: "sts-test.hello-world.read",
                                                                             request: URLRequest(url: AppEnvironment.stsHelloWorld))
                    happyPathResultLabel.showSuccessMessage("Success: \(String(decoding: data, as: UTF8.self))")
                } catch let error as ServerError {
                    happyPathResultLabel.showErrorMessage(error)
                } catch {
                    happyPathResultLabel.showErrorMessage()
                }
                happyPathButton.isLoading = false
            }
        } else {
            parentCoordinator?.accessTokenInvalidAction()
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
            if AppEnvironment.callingSTSEnabled {
                errorPathButton.titleLabel?.adjustsFontForContentSizeCategory = true
                errorPathButton.setTitle("Hello World Error", for: .normal)
            } else {
                errorPathButton.isHidden = true
            }
            errorPathButton.accessibilityIdentifier = "sts-error-path-button"
        }
    }
    
    @IBAction private func errorPathButtonAction(_ sender: Any) {
        errorPathButton.isLoading = true
        helloWorldErrorPath()
    }
    
    // Makes an unsuccessful request to the hello-world endpoint, the scope is invalid for this so a 400 response is returned
    private func helloWorldErrorPath() {
        if userStore.validAuthenticatedUser || TokenHolder.shared.validAccessToken {
            Task {
                do {
                    _ = try await networkClient.makeAuthorizedRequest(exchangeRequest: URLRequest(url: AppEnvironment.stsToken),
                                                                      scope: "sts-test.hello-world",
                                                                      request: URLRequest(url: AppEnvironment.stsHelloWorld))
                } catch let error as ServerError {
                    errorPathResultLabel.showErrorMessage(error)
                } catch {
                    errorPathResultLabel.showErrorMessage()
                }
                errorPathButton.isLoading = false
            }
        } else {
            parentCoordinator?.accessTokenInvalidAction()
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
            if AppEnvironment.callingSTSEnabled {
                unauthorizedPathButton.titleLabel?.adjustsFontForContentSizeCategory = true
                unauthorizedPathButton.setTitle("Hello World Unauthorized", for: .normal)
            } else {
                unauthorizedPathButton.isHidden = true
            }
            unauthorizedPathButton.accessibilityIdentifier = "sts-unauthorized-path-button"
        }
    }
    
    @IBAction private func unauthorizedPathButtonAction(_ sender: Any) {
        unauthorizedPathButton.isLoading = true
        helloWorldUnauthorizedPath()
    }
    
    // Makes an unsuccessful request to the hello-world endpoint, the endpoint returns a 401 unauthorized response
    private func helloWorldUnauthorizedPath() {
        if userStore.validAuthenticatedUser || TokenHolder.shared.validAccessToken {
            Task {
                do {
                    _ = try await networkClient.makeAuthorizedRequest(exchangeRequest: URLRequest(url: AppEnvironment.stsToken),
                                                                      scope: "sts-test.hello-world.read",
                                                                      request: URLRequest(url: AppEnvironment.stsHelloWorldError))
                } catch let error as ServerError {
                    unauthorizedPathResultLabel.showErrorMessage(error)
                } catch {
                    unauthorizedPathResultLabel.showErrorMessage()
                }
                unauthorizedPathButton.isLoading = false
            }
        } else {
            parentCoordinator?.accessTokenInvalidAction()
        }
    }
    
    @IBOutlet private var unauthorizedPathResultLabel: UILabel! {
        didSet {
            unauthorizedPathResultLabel.isHidden = true
            unauthorizedPathResultLabel.accessibilityIdentifier = "sts-unauthorized-path-result"
            unauthorizedPathResultLabel.font = .bodyBold
        }
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
