import CRIOrchestrator
import GDSAnalytics
import GDSCommon
import Logging
import Networking
import UIKit

final class HomeViewController: UITableViewController {
    let navigationTitle: GDSLocalisedString = "app_homeTitle"
    private var analyticsService: OneLoginAnalyticsService
    private let networkClient: NetworkClient
    private let criOrchestrator: CRIOrchestrator

    init(analyticsService: OneLoginAnalyticsService,
         networkClient: NetworkClient,
         criOrchestrator: CRIOrchestrator) {
        self.analyticsService = analyticsService.addingAdditionalParameters([
            OLTaxonomyKey.level2: OLTaxonomyValue.home,
            OLTaxonomyKey.level3: OLTaxonomyValue.undefined
        ])
        self.networkClient = networkClient
        self.criOrchestrator = criOrchestrator
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = navigationTitle.value
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.sizeToFit()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "OneLoginHomeScreenCell")
        if AppEnvironment.criOrchestratorEnabled {
            criOrchestrator.continueIdentityCheckIfRequired(over: self)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let screen = ScreenView(id: HomeAnalyticsScreenID.homeScreen.rawValue,
                                screen: HomeAnalyticsScreen.homeScreen,
                                titleKey: navigationTitle.stringKey)
        analyticsService.trackScreen(screen)
    }
}

extension HomeViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = ContentTileCell()
            cell.viewModel = .oneLoginCard(analyticsService: analyticsService,
                                           urlOpener: UIApplication.shared)
            return cell
        case 1:
            let idCheckCard = criOrchestrator.getIDCheckCard(viewController: self) {
                tableView.reloadData()
            }
            let tableViewCell = tableView.dequeueReusableCell(
                withIdentifier: "OneLoginHomeScreenCell",
                for: indexPath
            )
            
            tableViewCell.addSubview(idCheckCard.view)
            tableViewCell.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                tableViewCell.topAnchor.constraint(equalTo: idCheckCard.view.topAnchor),
                tableViewCell.bottomAnchor.constraint(equalTo: idCheckCard.view.bottomAnchor),
                tableViewCell.leadingAnchor.constraint(equalTo: idCheckCard.view.leadingAnchor),
                tableViewCell.trailingAnchor.constraint(equalTo: idCheckCard.view.trailingAnchor)
            ])
            tableViewCell.isHidden = !AppEnvironment.criOrchestratorEnabled
            
            return tableViewCell
        default:
            return UITableViewCell()
        }
    }
}
