import Coordination
import GDSCommon
import UIKit

final class TabbedViewController: BaseViewController {
    override var nibName: String? { "TabbedView" }
    
    private var viewModel: TabbedViewModel
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
        title = viewModel.navigationTitle.value
        configureTableView()
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
        headerView.updateEmail("example@email.com")
        resizeHeaderView()
        viewModel.isLoggedIn = true
    }
    
    func screenAnalytics() {
        viewModel.didAppear()
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
    
    private func configureTableView() {
        tableView.register(TabbedTableViewCell.self, forCellReuseIdentifier: TabbedTableViewCell.identifier)
        tableView.register(TabbedViewSectionFooter.self, forHeaderFooterViewReuseIdentifier: TabbedViewSectionFooter.identifier)
        tableView.register(TabbedViewSectionHeader.self, forHeaderFooterViewReuseIdentifier: TabbedViewSectionHeader.identifier)
        tableView.tableHeaderView = headerView
        tableView.sectionFooterHeight = UITableView.automaticDimension
        tableView.delegate = self
        tableView.dataSource = self
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TabbedTableViewCell.identifier, for: indexPath)
                as? TabbedTableViewCell else { return UITableViewCell() }
        cell.viewModel = viewModel.sectionModels[indexPath.section].tabModels[indexPath.row]
        return cell
    }
}

extension TabbedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: TabbedViewSectionHeader.identifier) as? TabbedViewSectionHeader
        headerView?.title = viewModel.sectionModels[section].sectionTitle
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return TabbedViewSectionHeader().intrinsicContentSize.height
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: TabbedViewSectionFooter.identifier) as? TabbedViewSectionFooter
        footerView?.title = viewModel.sectionModels[section].sectionFooter
        return footerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? TabbedTableViewCell else { return }
        cell.viewModel?.action?()
    }
}
