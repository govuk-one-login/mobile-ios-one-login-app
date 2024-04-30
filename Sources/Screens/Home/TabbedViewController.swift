import Coordination
import GDSCommon
import UIKit

final class TabbedViewController: BaseViewController {
    override var nibName: String? { "TabbedView" }
    
    private let viewModel: TabbedViewModel
    private let headerView: UIView?
    private var accessToken: String?
    
    init(viewModel: TabbedViewModel,
         headerView: UIView? = nil) {
        self.viewModel = viewModel
        self.headerView = headerView
        super.init(viewModel: viewModel,
                   nibName: "TabbedView",
                   bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(TabbedTableViewCell.self, forCellReuseIdentifier: "tabbedTableViewCell")
        tableView.tableHeaderView = headerView
        tableView.delegate = self
        tableView.dataSource = self
        title = viewModel.navigationTitle?.value
        
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.sizeToFit()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        resizeHeaderView()
    }
    
    @IBOutlet private var tableView: UITableView! {
        didSet {
            tableView.accessibilityIdentifier = "tabbed-view-table-view"
        }
    }
    
    func updateToken(accessToken: String?) {
        // TODO: DCMAW-8544 To be replaced by secure token JWT with capability to extract e-mail for display
        self.accessToken = accessToken
        guard let headerView = headerView as? SignInView else { return }
        headerView.updateEmail("sarahelizabeth_1991@gmail.com")
        resizeHeaderView()
    }
    
    private func resizeHeaderView() {
        guard self.isViewLoaded else { return }
        guard let headerView = tableView.tableHeaderView else {
            return
        }
        
        let size = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        
        if headerView.frame.height != size.height {
            headerView.frame.size.height = size.height
            tableView.tableHeaderView = headerView
        }
    }
}

extension TabbedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRowsInSection(section)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "tabbedTableViewCell", for: indexPath)
                as? TabbedTableViewCell else { return UITableViewCell() }
        cell.viewModel = viewModel.cellModels[indexPath.section][indexPath.row]
        return cell
    }
}

extension TabbedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = TabbedViewSectionHeader(title: viewModel.sectionHeaderTitles[section])
        return label
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return TabbedViewSectionHeader().intrinsicContentSize.height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? TabbedTableViewCell else { return }
        cell.viewModel?.action?()
    }
}
