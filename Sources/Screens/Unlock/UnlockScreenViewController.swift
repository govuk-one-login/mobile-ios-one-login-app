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

    @IBOutlet private var unlockButton: UnlockScreenButton! {
        didSet {
            unlockButton.setTitle("Unlock", for: .normal)
            unlockButton.accessibilityIdentifier = "unlock-screen-button"
        }
    }

    @IBAction private func unlockScreenButton(_ sender: Any) {
        viewModel.primaryButtonViewModel.action()
    }
}
