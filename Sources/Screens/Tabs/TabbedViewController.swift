import Combine
import Coordination
import GDSCommon
import Logging
import UIKit

final class TabbedViewController: BaseViewController {
    override var nibName: String? { "TabbedView" }
    
    private let viewModel: TabbedViewModel
    private let userProvider: UserProvider
    private var analyticsPreference: AnalyticsPreferenceStore
    private var cancellables = Set<AnyCancellable>()

    init(viewModel: TabbedViewModel,
         userProvider: UserProvider,
         analyticsPreference: AnalyticsPreferenceStore) {
        self.viewModel = viewModel
        self.userProvider = userProvider
        self.analyticsPreference = analyticsPreference
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
        
        updateEmail()
        subscribeToUsers()
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.sizeToFit()
        guard let analyticsAccepted = analyticsPreference.hasAcceptedAnalytics else { return }
        analyticsSwitch.setOn(analyticsAccepted, animated: true)
    }
    
    @IBOutlet private var tableView: UITableView! {
        didSet {
            tableView.accessibilityIdentifier = "tabbed-view-table-view"
        }
    }
    
    private func subscribeToUsers() {
        userProvider.user
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.updateEmail()
            }.store(in: &cancellables)
    }
    
    func updateEmail() {
        // temporary solution to stop app from freezing. Similar resolution here: https://stackoverflow.com/questions/74868322/tableview-freeze
        self.tableView.reloadRows(at: [.first], with: .none)
    }


    @IBOutlet private var analyticsSwitch: UISwitch! {
        didSet {
            analyticsSwitch.accessibilityIdentifier = "tabbed-view-analytics-switch"
        }
    }
    
    @IBAction private func updateAnalytics(_ sender: UISwitch) {
        analyticsPreference.hasAcceptedAnalytics?.toggle()
    }
    
    private func configureTableView() {
        tableView.register(TabbedTableViewCell.self, forCellReuseIdentifier: TabbedTableViewCell.identifier)
        tableView.register(TabbedViewSectionFooter.self, forHeaderFooterViewReuseIdentifier: TabbedViewSectionFooter.identifier)
        tableView.register(TabbedViewSectionHeader.self, forHeaderFooterViewReuseIdentifier: TabbedViewSectionHeader.identifier)
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
        
        if cell.viewModel?.accessoryView == TabbedViewSectionModel.linkDisclosureArrow {
            cell.accessibilityHint = GDSLocalisedString(stringKey: "app_externalBrowser").value
        }
        
        if viewModel.sectionModels[indexPath.section].sectionTitle == "app_settingsSubtitle2" {
            cell.accessoryView = analyticsSwitch
        }
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

extension IndexPath {
    static let first = IndexPath.init(row: 0, section: 0)
}
