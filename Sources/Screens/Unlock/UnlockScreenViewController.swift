import GDSCommon
import UIKit

class UnlockScreenViewController: BaseViewController {
    override var nibName: String? { "UnlockScreen" }
    
    let viewModel: UnlockScreenViewModel
    
    init(viewModel: UnlockScreenViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: "UnlockScreen", bundle: .main)
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
        }
    }
    
    @IBAction private func unlockScreenButton(_ sender: Any) {
        viewModel.primaryButtonViewModel.action()
    }
}
