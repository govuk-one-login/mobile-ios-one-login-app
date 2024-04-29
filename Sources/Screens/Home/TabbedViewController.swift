import GDSCommon
import UIKit

final class TabbedViewController: BaseViewController {

    override var nibName: String? { "TabbedView" }
    @IBOutlet private var tableView: UITableView!
    let headerView = SignInView()
    let viewModel: TabbedViewModel
    
    init(viewModel: TabbedViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel,
                   nibName: "TabbedView",
                   bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = viewModel
        tableView.dataSource = viewModel.dataSource
        title = "Home"
        navigationController?.navigationBar.prefersLargeTitles = true
    }


    
    override func viewDidLayoutSubviews() {
         super.viewDidLayoutSubviews()

         guard let headerView = tableView.tableHeaderView else {
             return
         }

         // The table view header is created with the frame size set in
         // the Storyboard. Calculate the new size and reset the header
         // view to trigger the layout.

         // Calculate the minimum height of the header view that allows
         // the text label to fit its preferred width.

         let size = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)

         if headerView.frame.size.height != size.height {
             headerView.frame.size.height = size.height

             // Need to set the header view property of the table view
             // to trigger the new layout. Be careful to only do this
             // once when the height changes or we get stuck in a layout loop.

             tableView.tableHeaderView = headerView

             // Now that the table view header is sized correctly have
             // the table view redo its layout so that the cells are
             // correcly positioned for the new header size.

             // This only seems to be necessary on iOS 9.

             tableView.layoutIfNeeded()
         }
     }
 
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
