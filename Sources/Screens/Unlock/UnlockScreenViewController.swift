import GDSCommon
import UIKit

class UnlockScreenViewController: BaseViewController {
    override var nibName: String? { "UnlockScreen" }
    
    let viewModel: UnlockScreenViewModel
    
    init(viewModel: UnlockScreenViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: "UnlockScreen", bundle: .main)
    }
    
    override func viewDidLoad() {
        view.accessibilityViewIsModal = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBOutlet private var unlockButton: UIButton! {
        didSet {
            unlockButton.titleLabel?.adjustsFontForContentSizeCategory = true
            unlockButton.setTitle(viewModel.primaryButtonViewModel.title.value, for: .normal)
            unlockButton.titleLabel?.font = UIFont(style: .title3, weight: .bold)
            unlockButton.accessibilityIdentifier = "unlock-screen-button"
            unlockButton.isHidden = true
        }
    }
    
    @IBOutlet private var oneLoginLogo: UIImageView! {
        didSet {
            oneLoginLogo.accessibilityIdentifier = "unlock-screen-one-login-logo"
        }
    }
    
    @IBOutlet private var loadingSpinner: UIActivityIndicatorView! {
        didSet {
            loadingSpinner.accessibilityIdentifier = "unlock-screen-loading-spinner"
        }
    }
    
    @IBOutlet private var loadingLabel: UILabel! {
        didSet {
            loadingLabel.text = "Loading"
            loadingLabel.accessibilityIdentifier = "unlock-screen-loading-label"
            loadingLabel.accessibilityLabel = viewModel.accessibilityLabel.value
        }
    }
    
    @IBAction private func unlockScreenButton(_ sender: Any) {
        viewModel.primaryButtonViewModel.action()
    }
    
    @IBOutlet private var loadingStackView: UIStackView! {
        didSet {
            loadingStackView.accessibilityIdentifier = "unlock-screen-loading-stack-view"
        }
    }
    
    var isLoading: Bool = true {
        didSet {
            loadingStackView.isHidden = !isLoading
            unlockButton.isHidden = isLoading
        }
    }
}
