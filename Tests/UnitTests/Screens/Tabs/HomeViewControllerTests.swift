import CRIOrchestrator
import GDSAnalytics
import Networking
@testable import OneLogin
import XCTest

@MainActor
final class HomeViewControllerTests: XCTestCase {
    var mockAnalyticsService: MockAnalyticsService!
    var mockNetworkClient: NetworkClient!
    var mockCRIOrchestrator: MockCRIOrchestrator!
    var sut: HomeViewController!
    
    override func setUp() {
        super.setUp()
        
        mockAnalyticsService = MockAnalyticsService()
        mockNetworkClient = NetworkClient()
        mockNetworkClient.authorizationProvider = MockAuthenticationProvider()
        
        mockCRIOrchestrator = MockCRIOrchestrator()
        sut = HomeViewController(analyticsService: mockAnalyticsService,
                                 networkClient: mockNetworkClient,
                                 criOrchestrator: mockCRIOrchestrator)
    }
    
    override func tearDown() {
        mockAnalyticsService = nil
        mockNetworkClient = nil
        mockCRIOrchestrator = nil
        sut = nil
        
        super.tearDown()
    }
}

extension HomeViewControllerTests {
    func test_header_Image() {
        XCTAssertTrue(try sut.headerImage.isAccessibilityElement)
    }
    
    func test_page() {
        sut.beginAppearanceTransition(true, animated: false)
        sut.endAppearanceTransition()
        XCTAssertEqual(sut.navigationTitle.stringKey, "app_homeTitle")
    }
    
    func test_insertIDCheck() throws {
        XCTAssertEqual(sut.numberOfSections(in: try sut.tableView), 2)
        mockCRIOrchestrator.hostingViewController.view.isHidden = false
        mockCRIOrchestrator.streamContinuation?.yield(.show)
        let tableView = try sut.tableView
        waitForTruth(
            self.sut.numberOfSections(in: tableView) == 3,
            timeout: 5
        )
    }
    
    func test_deleteIDCheck() throws {
        mockCRIOrchestrator.idCheckJourney = true
        XCTAssertEqual(sut.numberOfSections(in: try sut.tableView), 3)
        mockCRIOrchestrator.hostingViewController.view.isHidden = true
        mockCRIOrchestrator.streamContinuation?.yield(.hide)
        let tableView = try sut.tableView
        waitForTruth(
            self.sut.numberOfSections(in: tableView) == 2,
            timeout: 5
        )
    }
    
    func test_numberOfSections() {
        XCTAssertEqual(sut.numberOfSections(in: try sut.tableView), 2)
    }
    
    func test_numberOfSectionsWithIDCheck() {
        mockCRIOrchestrator.idCheckJourney = true
        XCTAssertEqual(sut.numberOfSections(in: try sut.tableView), 3)
    }
    
    func test_numberOfRowsInSection_IDCheck() {
        mockCRIOrchestrator.idCheckJourney = true
        XCTAssertEqual(sut.tableView(try sut.tableView, numberOfRowsInSection: 0), 1)
        XCTAssertEqual(sut.tableView(try sut.tableView, numberOfRowsInSection: 1), 1)
        XCTAssertEqual(sut.tableView(try sut.tableView, numberOfRowsInSection: 2), 1)
    }
    
    func test_welcomeTileCell_viewModel() throws {
        let servicesTile = sut.tableView(
            try sut.tableView,
            cellForRowAt: IndexPath(row: 0, section: 0)
        ) as? ContentTileCell
        XCTAssertTrue(servicesTile?.viewModel is WelcomeTileViewModel)
    }
    
    func test_purposeTileCell_viewModel() throws {
        let servicesTile = sut.tableView(
            try sut.tableView,
            cellForRowAt: IndexPath(row: 0, section: 1)
        ) as? ContentTileCell
        XCTAssertTrue(servicesTile?.viewModel is PurposeTileViewModel)
    }
    
    func test_idCheckTileCell_isDisplayed() throws {
        mockCRIOrchestrator.idCheckJourney = true
        let idCell = sut.tableView(
            try sut.tableView,
            cellForRowAt: IndexPath(row: 0, section: 0)
        )
        let welcomeCell = sut.tableView(
            try sut.tableView,
            cellForRowAt: IndexPath(row: 0, section: 1)
        )
        let purposeCell = sut.tableView(
            try sut.tableView,
            cellForRowAt: IndexPath(row: 0, section: 2)
        )
        XCTAssertFalse(idCell.isHidden)
        XCTAssertTrue((idCell as? ContentTileCell) == nil)
        XCTAssertFalse(welcomeCell.isHidden)
        XCTAssertTrue((welcomeCell as? ContentTileCell) != nil)
        XCTAssertFalse(purposeCell.isHidden)
        XCTAssertTrue((purposeCell as? ContentTileCell) != nil)
    }
    
    func test_viewDidAppear() {
        XCTAssertEqual(mockAnalyticsService.screenViews.count, 0)
        sut.beginAppearanceTransition(true, animated: false)
        sut.endAppearanceTransition()
        XCTAssertEqual(mockAnalyticsService.screenViews.count, 1)
        let screen = ScreenView(id: HomeAnalyticsScreenID.homeScreen.rawValue,
                                screen: HomeAnalyticsScreen.homeScreen,
                                titleKey: "app_homeTitle")
        XCTAssertEqual(mockAnalyticsService.screenViews as? [ScreenView], [screen])
        XCTAssertEqual(mockAnalyticsService.screenParamsLogged, screen.parameters)
        XCTAssertEqual(mockAnalyticsService.additionalParameters[OLTaxonomyKey.level2] as? String, OLTaxonomyValue.home)
        XCTAssertEqual(mockAnalyticsService.additionalParameters[OLTaxonomyKey.level3] as? String, OLTaxonomyValue.undefined)
    }
}

extension HomeViewController {
    var tableView: UITableView {
        get throws {
            try XCTUnwrap(view[child: "home-table-view"])
        }
    }
    
    var headerImage: UIImageView {
        get throws {
            try XCTUnwrap(view[child: "home-header-image"])
        }
    }
}
