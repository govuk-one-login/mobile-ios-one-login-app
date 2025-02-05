import CRIOrchestrator
import GDSAnalytics
import Networking
@testable import OneLogin
import XCTest

@MainActor
final class HomeViewControllerTests: XCTestCase {
    var mockAnalyticsService: MockAnalyticsService!
    var mockNetworkClient: NetworkClient!
    var criOrchestrator: CRIOrchestrator!
    var sut: HomeViewController!
    
    override func setUp() {
        super.setUp()
        
        mockAnalyticsService = MockAnalyticsService()
        mockNetworkClient = NetworkClient()
        mockNetworkClient.authorizationProvider = MockAuthenticationProvider()
        
        criOrchestrator = CRIOrchestrator(analyticsService: mockAnalyticsService,
                                          networkClient: mockNetworkClient)
        sut = HomeViewController(analyticsService: mockAnalyticsService,
                                 networkClient: mockNetworkClient,
                                 criOrchestrator: criOrchestrator)
    }
    
    override func tearDown() {
        mockAnalyticsService = nil
        mockNetworkClient = nil
        criOrchestrator = nil
        sut = nil
        
        AppEnvironment.updateFlags(
            releaseFlags: [:],
            featureFlags: [:]
        )
        
        super.tearDown()
    }
}

extension HomeViewControllerTests {
    func test_page() {
        sut.beginAppearanceTransition(true, animated: false)
        sut.endAppearanceTransition()
        XCTAssertEqual(sut.navigationTitle.stringKey, "app_homeTitle")
    }
    
    func test_numberOfSections() {
        XCTAssertEqual(sut.numberOfSections(in: sut.tableView), 2)
    }

    func test_numbeOfRowsInSection() {
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 0), 1)
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 1), 1)
    }

    func test_contentTileCell_viewModel() {
        let servicesTile = sut.tableView(
            sut.tableView,
            cellForRowAt: IndexPath(row: 0, section: 0)
        ) as? ContentTileCell
        XCTAssertTrue(servicesTile?.viewModel is ServicesTileViewModel)
    }
    
    func test_idCheckTileCell_isVisible() {
        AppEnvironment.updateFlags(
            releaseFlags: [:],
            featureFlags: [FeatureFlagsName.enableCRIOrchestrator.rawValue: true]
        )
        UINavigationController().setViewControllers([sut], animated: false)
        let servicesTile = sut.tableView(
            sut.tableView,
            cellForRowAt: IndexPath(row: 0, section: 1)
        )
        XCTAssertFalse(servicesTile.isHidden)
    }

    func test_idCheckTileCell_isHidden() {
        UINavigationController().setViewControllers([sut], animated: false)
        let servicesTile = sut.tableView(
            sut.tableView,
            cellForRowAt: IndexPath(row: 0, section: 1)
        )
        XCTAssertTrue(servicesTile.isHidden)
    }
    
    func test_viewDidAppear() {
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 0)
        sut.beginAppearanceTransition(true, animated: false)
        sut.endAppearanceTransition()
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 1)
        let screen = ScreenView(id: HomeAnalyticsScreenID.homeScreen.rawValue,
                                screen: HomeAnalyticsScreen.homeScreen,
                                titleKey: "app_homeTitle")
        XCTAssertEqual(mockAnalyticsService.screensVisited, [screen.name])
        XCTAssertEqual(mockAnalyticsService.screenParamsLogged, screen.parameters)
        XCTAssertEqual(mockAnalyticsService.additionalParameters["taxonomy_level2"] as? String, AppTaxonomy.home.rawValue)
        XCTAssertEqual(mockAnalyticsService.additionalParameters["taxonomy_level3"] as? String, "undefined")
    }
}
