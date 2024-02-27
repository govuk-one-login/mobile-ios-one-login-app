import GDSCommon
import UIKit

class UnlockScreenViewController: UIViewController {
    override var nibName: String? { "UnlockScreen" }
    let viewModel: UnlockScreenViewModel

    init(viewModel: UnlockScreenViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "UnlockScreen", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    @IBOutlet private var unlockButton: RoundedButton! {
        didSet {
            unlockButton.setTitle("Unlock", for: .normal)
            unlockButton.accessibilityIdentifier = "unlock-screen-primary-button"
        }
    }

    @IBAction private func unlockScreenButton(_ sender: Any) {
        unlockButton.isLoading = true
        viewModel.primaryButtonViewModel.action()
        unlockButton.isLoading = false
    }
}
