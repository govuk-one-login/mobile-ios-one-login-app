import CRIOrchestrator
import GDSAnalytics
import GDSCommon
import Logging
import Networking
import UIKit

final class HomeViewController: UITableViewController {
    let analyticsService: AnalyticsService
    let navigationTitle: GDSLocalisedString = "app_homeTitle"

    init(analyticsService: AnalyticsService) {
        var tempAnalyticsService = analyticsService
        tempAnalyticsService.setAdditionalParameters(appTaxonomy: .home)
        self.analyticsService = tempAnalyticsService
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
            cell.viewModel = .yourServices(analyticsService: analyticsService,
                                           urlOpener: UIApplication.shared)
            return cell
        case 1:
            let tableViewCell = UITableViewCell()
            guard let navigationController else {
                return tableViewCell
            }
            let idCheckCard = CRIOrchestrator(analyticsService: analyticsService,
                                              networkClient: NetworkClient())
                .getIDCheckCard(viewController: navigationController)
            tableViewCell.addSubview(idCheckCard.view)
            return tableViewCell
        default:
            return UITableViewCell()
        }
    }
}
