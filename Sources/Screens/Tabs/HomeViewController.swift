import GDSAnalytics
import GDSCommon
import Logging
import UIKit

final class HomeViewController: UITableViewController {
    let analyticsService: AnalyticsService
    let navigationTitle: GDSLocalisedString = "app_homeTitle"
    let viewModel: ServicesTileViewModel

    init(analyticsService: AnalyticsService,
         viewModel: ServicesTileViewModel) {
        var tempAnalyticsService = analyticsService
        tempAnalyticsService.setAdditionalParameters(appTaxonomy: .home)
        self.analyticsService = tempAnalyticsService
        self.viewModel = viewModel
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
        1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        HomeScreenTile.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ContentTileCell()
        switch HomeScreenTile(rawValue: indexPath.row) {
        case .yourServices:
            cell.viewModel = .yourServices(analyticsService: analyticsService,
                                           urlOpener: UIApplication.shared)
        default:
            break
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.cardTapped()
    }
}

enum HomeScreenTile: Int, CaseIterable {
    case yourServices
}
