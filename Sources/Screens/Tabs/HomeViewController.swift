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
    private let criOrchestrator: CRIOrchestration
    
    private var idCheckCard: UIViewController?

    init(analyticsService: OneLoginAnalyticsService,
         networkClient: NetworkClient,
         criOrchestrator: CRIOrchestration) {
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
        tableView.register(ContentTileCell.self, forCellReuseIdentifier: "ContentTileCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "OneLoginHomeScreenCell")
        idCheckCard = criOrchestrator.getIDCheckCard(viewController: self) { [unowned self] in
            self.tableView.reloadData()
        }
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
        guard let idCheckCard else { return 1 }
        return idCheckCard.view.isHidden ? 1 : 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            guard let idCheckCard else { return getOneLoginCard(indexPath: indexPath) }
            if !idCheckCard.view.isHidden {
                return getIDCheckCard(indexPath: indexPath)
            }
            return getOneLoginCard(indexPath: indexPath)
        case 1:
            return getOneLoginCard(indexPath: indexPath)
        default:
            return UITableViewCell()
        }
    }
    
    func getOneLoginCard(indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "ContentTileCell",
            for: indexPath
        ) as? ContentTileCell else {
            preconditionFailure()
        }
        cell.viewModel = .oneLoginCard(analyticsService: analyticsService,
                                       urlOpener: UIApplication.shared)
        return cell
    }
    
    func getIDCheckCard(indexPath: IndexPath) -> UITableViewCell {
        guard let idCheckCard else {
            preconditionFailure("")
        }
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "OneLoginHomeScreenCell",
            for: indexPath
        )
        
        idCheckCard.view.translatesAutoresizingMaskIntoConstraints = false
        cell.isHidden = !AppEnvironment.criOrchestratorEnabled || idCheckCard.view.isHidden
        cell.contentView.addSubview(idCheckCard.view)
        
        NSLayoutConstraint.activate([
            idCheckCard.view.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
            idCheckCard.view.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
            idCheckCard.view.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
            idCheckCard.view.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor)
        ])

        return cell
    }
}

@MainActor
protocol CRIOrchestration {
    func continueIdentityCheckIfRequired(over viewController: UIViewController)
    
    func getIDCheckCard(
        viewController: UIViewController,
        completion: @escaping () -> Void
    ) -> UIViewController
}

extension CRIOrchestrator: CRIOrchestration { }
