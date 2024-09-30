import GDSCommon
import Logging
import UIKit

final class ContentViewController {
    var nibName: String? { "ContentView" }
    
    private var viewModel: ContentViewModel
    private let contentView: UIView?
    
    init(viewModel: ContentViewModel,
         contentView: UIView? = nil) {
        self.viewModel = viewModel
        self.contentView = contentView
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBOutlet var tableView: UITableView! {
        didSet {
            tableView.accessibilityIdentifier = "content-view-table-view"
        }
    }
    
    
}
