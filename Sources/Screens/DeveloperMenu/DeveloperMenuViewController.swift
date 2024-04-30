import GDSCommon
import Networking
import UIKit

final class DeveloperMenuViewController: BaseViewController {
    override var nibName: String? { "DeveloperMenu" }

    let viewModel: DeveloperMenuViewModel
    let networkClient: NetworkClient?

    init(viewModel: DeveloperMenuViewModel,
         networkClient: NetworkClient?) {
        self.viewModel = viewModel
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
                happyPathButton.accessibilityIdentifier = "sts-happy-path-button"
            } else {
                happyPathButton.isHidden = true
            }
        }
    }

    @IBAction private func happyPathButtonAction(_ sender: Any) {
        happyPathButton.isLoading = true
        helloWorldHappyPath()
    }

    private func helloWorldHappyPath() {
        Task {
            do {
                let data = try await networkClient?.makeAuthorizedRequest(exchangeRequest: URLRequest(url: AppEnvironment.stsToken),
                                                                          scope: "sts-test.hello-world.read",
                                                                          request: URLRequest(url: AppEnvironment.stsHelloWorld))
                happyPathResultLabel.text = "Success: \(String(data: data!, encoding: .utf8) ?? "no body")"
                happyPathResultLabel.font = UIFont.bodyBold
                happyPathResultLabel.textColor = .gdsGreen
                happyPathResultLabel.isHidden = false
            } catch let error as ServerError {
                happyPathResultLabel.text = "Error code: \(error.errorCode)\nEndpoint: \(error.endpoint ?? "missing")"
                happyPathResultLabel.font = UIFont.bodyBold
                happyPathResultLabel.textColor = .red
                happyPathResultLabel.isHidden = false
            } catch {
                happyPathResultLabel.text = "Error"
                happyPathResultLabel.font = UIFont.bodyBold
                happyPathResultLabel.textColor = .red
                happyPathResultLabel.isHidden = false
            }
            happyPathButton.isLoading = false
        }
    }

    @IBOutlet private var happyPathResultLabel: UILabel! {
        didSet {
            happyPathResultLabel.isHidden = true
            happyPathResultLabel.accessibilityIdentifier = "sts-happy-path-result"
        }
    }

    @IBOutlet private var unhappyPathButton: RoundedButton! {
        didSet {
            if AppEnvironment.callingSTSEnabled {
                unhappyPathButton.titleLabel?.adjustsFontForContentSizeCategory = true
                unhappyPathButton.setTitle("Hello World Error", for: .normal)
                unhappyPathButton.accessibilityIdentifier = "sts-unhappy-path-button"
            } else {
                unhappyPathButton.isHidden = true
            }
        }
    }

    @IBAction private func unhappyPathButtonAction(_ sender: Any) {
        unhappyPathButton.isLoading = true
        helloWorldUnhappyPath()
    }

    private func helloWorldUnhappyPath() {
        Task {
            do {
                let errorAuthProvider = TokenHolder()
                errorAuthProvider.accessToken = "notPermissible"
                let errorNetworkClient = NetworkClient(authenticationProvider: errorAuthProvider)
                _ = try await errorNetworkClient.makeAuthorizedRequest(exchangeRequest: URLRequest(url: AppEnvironment.stsToken),
                                                                       scope: "sts-test.hello-world.read",
                                                                       request: URLRequest(url: AppEnvironment.stsHelloWorld))
            } catch let error as ServerError {
                unhappyPathResultLabel.text = "Error code: \(error.errorCode)\nEndpoint: \(error.endpoint ?? "missing")"
                unhappyPathResultLabel.font = UIFont.bodyBold
                unhappyPathResultLabel.textColor = .red
                unhappyPathResultLabel.isHidden = false
            } catch {
                unhappyPathResultLabel.text = "Error"
                unhappyPathResultLabel.font = UIFont.bodyBold
                unhappyPathResultLabel.textColor = .red
                unhappyPathResultLabel.isHidden = false
            }
            unhappyPathButton.isLoading = false
        }
    }

    @IBOutlet private var unhappyPathResultLabel: UILabel! {
        didSet {
            unhappyPathResultLabel.isHidden = true
            unhappyPathResultLabel.accessibilityIdentifier = "sts-unhappy-path-result"
        }
    }
}
