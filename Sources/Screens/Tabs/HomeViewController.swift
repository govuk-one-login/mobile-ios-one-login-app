import CRIOrchestrator
import GDSAnalytics
import GDSCommon
import Logging
import Networking
import UIKit

@MainActor
protocol CRIOrchestration {
    func continueIdentityCheckIfRequired(over viewController: UIViewController)
    
    func getIDCheckCard(
        viewController: UIViewController,
        externalStream: IDCheckExternalStream
    ) -> UIViewController
}

extension CRIOrchestrator: CRIOrchestration { }

final class HomeViewController: BaseViewController {
    override var nibName: String? { "HomeView" }
    
    let navigationTitle: GDSLocalisedString = "app_homeTitle"
    private var analyticsService: OneLoginAnalyticsService
    private let networkClient: NetworkClient
    private let criOrchestrator: CRIOrchestration
    let spaceBetweenSections: CGFloat = 16
    
    private var idCheckCard: UIViewController?
    private let idCheckCardUpdateStream = AsyncStream.makeStream(of: CardStatus.self)
    
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
                   nibName: "HomeView",
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
        listenForCardUpdates()
        idCheckCard = criOrchestrator.getIDCheckCard(
            viewController: self,
            externalStream: idCheckCardUpdateStream
        )
        criOrchestrator.continueIdentityCheckIfRequired(over: self)
    }
    
    func listenForCardUpdates() {
        Task {
            for await status in idCheckCardUpdateStream.stream {
                switch status {
                case .hide:
                    tableView.deleteSections(IndexSet(integer: 0), with: .fade)
                case .show:
                    tableView.insertSections(IndexSet(integer: 0), with: .fade)
                }
            }
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
        guard let idCheckCard else { return 2 }
        return idCheckCard.view.isHidden ? 2 : 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0: return spaceBetweenSections
        default: return spaceBetweenSections / 2
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return spaceBetweenSections / 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            guard let idCheckCard, !idCheckCard.view.isHidden else {
                return getWelcomeCard(indexPath: indexPath)
            }
            return getIDCheckCard(indexPath: indexPath)
        case 1:
            guard let idCheckCard, !idCheckCard.view.isHidden else {
                return getPurposeCard(indexPath: indexPath)
            }
            return getWelcomeCard(indexPath: indexPath)
        case 2:
            return getPurposeCard(indexPath: indexPath)
        default:
            return UITableViewCell()
        }
    }
    
    private func getWelcomeCard(indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "ContentTileCell",
            for: indexPath
        ) as? ContentTileCell else {
            preconditionFailure()
        }
        cell.viewModel = WelcomeTileViewModel()
        
        return cell
    }
    
    private func getPurposeCard(indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "ContentTileCell",
            for: indexPath
        ) as? ContentTileCell else {
            preconditionFailure()
        }
        cell.viewModel = PurposeTileViewModel()
        
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
        cell.isHidden = idCheckCard.view.isHidden
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
