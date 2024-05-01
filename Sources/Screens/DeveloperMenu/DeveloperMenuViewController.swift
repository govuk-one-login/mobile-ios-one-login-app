import GDSCommon
import Networking
import UIKit

final class DeveloperMenuViewController: BaseViewController {
    override var nibName: String? { "DeveloperMenu" }
    
    let viewModel: DeveloperMenuViewModel
    let networkClient: RequestAuthorizing?
    
    init(viewModel: DeveloperMenuViewModel,
         networkClient: RequestAuthorizing?) {
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
    
    private func helloWorldHappyPath() {
        Task {
            do {
                let data = try await networkClient?.makeAuthorizedRequest(exchangeRequest: URLRequest(url: AppEnvironment.stsToken),
                                                                          scope: "sts-test.hello-world.read",
                                                                          request: URLRequest(url: AppEnvironment.stsHelloWorld))
                happyPathResultLabel.showSuccessMessage("Success: \(String(data: data!, encoding: .utf8) ?? "no body")")
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
    
    @IBOutlet private var unhappyPathButton: RoundedButton! {
        didSet {
            if AppEnvironment.callingSTSEnabled {
                unhappyPathButton.titleLabel?.adjustsFontForContentSizeCategory = true
                unhappyPathButton.setTitle("Hello World Error", for: .normal)
            } else {
                unhappyPathButton.isHidden = true
            }
            unhappyPathButton.accessibilityIdentifier = "sts-unhappy-path-button"
        }
    }
    
    @IBAction private func unhappyPathButtonAction(_ sender: Any) {
        unhappyPathButton.isLoading = true
        helloWorldUnhappyPath()
    }
    
    private func helloWorldUnhappyPath() {
        Task {
            do {
                _ = try await networkClient?.makeAuthorizedRequest(exchangeRequest: URLRequest(url: AppEnvironment.stsToken),
                                                                   scope: "sts-test.hello-world",
                                                                   request: URLRequest(url: AppEnvironment.stsHelloWorld))
            } catch let error as ServerError {
                unhappyPathResultLabel.showErrorMessage(error)
            } catch {
                unhappyPathResultLabel.showErrorMessage()
            }
            unhappyPathButton.isLoading = false
        }
    }
    
    @IBOutlet private var unhappyPathResultLabel: UILabel! {
        didSet {
            unhappyPathResultLabel.isHidden = true
            unhappyPathResultLabel.accessibilityIdentifier = "sts-unhappy-path-result"
            unhappyPathResultLabel.font = .bodyBold
        }
    }
}

fileprivate extension UILabel {
    func showErrorMessage(_ error: ServerError? = nil) {
        textColor = .red
        isHidden = false
        if let error {
            self.text = "Error code: \(error.errorCode)\nEndpoint: \(error.endpoint ?? "missing")"
        } else {
            self.text = "Error"
        }
    }

    func showSuccessMessage(_ message: String) {
        self.textColor = .gdsGreen
        isHidden = false
        text = message
    }
}
