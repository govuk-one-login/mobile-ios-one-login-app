import CRIOrchestrator
import GDSAnalytics
import GDSCommon
import Logging
import Networking
import UIKit

final class HomeViewController: BaseViewController {
    override var nibName: String? { "HomeViewController" }
    
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
        super.init(viewModel: nil,
                   nibName: "HomeViewController",
                   bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBOutlet private var headerImage: UIImageView! {
        didSet {
            headerImage.isAccessibilityElement = true
            headerImage.accessibilityIdentifier = "home-header-image"
            headerImage.accessibilityTraits = .header
            headerImage.accessibilityHint = "GOV.UK One Login"
        }
    }
    
    @IBOutlet private var tableView: UITableView! {
        didSet {
            tableView.accessibilityIdentifier = "home-table-view"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(ContentTileCell.self, forCellReuseIdentifier: "ContentTileCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "OneLoginHomeScreenCell")
        tableView.delegate = self
        tableView.dataSource = self
        idCheckCard = criOrchestrator.getIDCheckCard(viewController: self) { [unowned self] in
            self.tableView.reloadData()
        }
        if AppEnvironment.criOrchestratorEnabled {
            criOrchestrator.continueIdentityCheckIfRequired(over: self)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let screen = ScreenView(id: HomeAnalyticsScreenID.homeScreen.rawValue,
                                screen: HomeAnalyticsScreen.homeScreen,
                                titleKey: navigationTitle.stringKey)
        analyticsService.trackScreen(screen)
    }
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let idCheckCard else { return 1 }
        return idCheckCard.view.isHidden ? 1 : 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    
    private func getOneLoginCard(indexPath: IndexPath) -> UITableViewCell {
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
    
    private func getIDCheckCard(indexPath: IndexPath) -> UITableViewCell {
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
