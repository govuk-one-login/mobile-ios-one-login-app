import GDSCommon
import UIKit

final class DeveloperMenuViewController: BaseViewController {
    override var nibName: String? { "DeveloperMenu" }
    
    init() {
        super.init(viewModel: DeveloperMenuViewModel(),
                   nibName: "DeveloperMenu",
                   bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
