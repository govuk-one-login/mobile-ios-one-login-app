import CRIOrchestrator
@testable import DesignSystem
import GDSAnalytics
import Networking
@testable import OneLogin
import Testing
import UIKit

@MainActor
struct HomeViewControllerTests {
    var mockAnalyticsService: MockAnalyticsService!
    var mockNetworkClient: NetworkClient!
    var mockCRIOrchestrator: MockCRIOrchestrator!
    var sut: HomeViewController!
    
    init() {
        mockAnalyticsService = MockAnalyticsService()
        mockNetworkClient = NetworkClient()
        mockNetworkClient.authorizationProvider = MockAuthenticationProvider()
        
        mockCRIOrchestrator = MockCRIOrchestrator()
        sut = HomeViewController(analyticsService: mockAnalyticsService,
                                 criOrchestrator: mockCRIOrchestrator)
    }
}

extension HomeViewControllerTests {
    @Test
    func test_header_Image() throws {
        #expect(try sut.headerImage.isAccessibilityElement)
    }
    
    @Test
    func test_page() {
        sut.beginAppearanceTransition(true, animated: false)
        sut.endAppearanceTransition()
        #expect(sut.navigationTitle.stringKey == "app_homeTitle")
    }
    
    @Test
    func test_insertIDCheck() async throws {
        #expect(sut.numberOfSections(in: try sut.tableView) == 2)
        mockCRIOrchestrator.hostingViewController.view.isHidden = false
        mockCRIOrchestrator.streamContinuation?.yield(.show)
        let tableView = try sut.tableView
        #expect( await eventually { self.sut.numberOfSections(in: tableView) == 3 })
    }
    
    @Test
    func test_deleteIDCheck() async throws {
        mockCRIOrchestrator.idCheckJourney = true
        #expect(sut.numberOfSections(in: try sut.tableView) == 3)
        mockCRIOrchestrator.hostingViewController.view.isHidden = true
        mockCRIOrchestrator.streamContinuation?.yield(.hide)
        let tableView = try sut.tableView
        #expect( await eventually { self.sut.numberOfSections(in: tableView) == 2 })
    }
    
    @Test
    func test_numberOfSections() throws {
        #expect(sut.numberOfSections(in: try sut.tableView) == 2)
    }
    
    @Test
    func test_numberOfSectionsWithIDCheck() throws {
        mockCRIOrchestrator.idCheckJourney = true
        #expect(sut.numberOfSections(in: try sut.tableView) == 3)
    }
    
    @Test
    func test_numberOfRowsInSection_IDCheck() throws {
        mockCRIOrchestrator.idCheckJourney = true
        #expect(sut.tableView(try sut.tableView, numberOfRowsInSection: 0) == 1)
        #expect(sut.tableView(try sut.tableView, numberOfRowsInSection: 1) == 1)
        #expect(sut.tableView(try sut.tableView, numberOfRowsInSection: 2) == 1)
    }
    
    @Test
    func test_welcomeTileCell_viewModel() throws {
        let servicesTile = sut.tableView(
            try sut.tableView,
            cellForRowAt: IndexPath(row: 0, section: 0)
        ) as? ContentTileCell
        let viewModel = try #require(servicesTile?.viewModel)
        
        let title = viewModel.contentItems.first as? GDSTextViewModel
        #expect(title?.title.stringKey == "app_welcomeTileHeader")
        #expect(title?.title.value == "Welcome")
        
        let body = viewModel.contentItems.last as? GDSTextViewModel
        #expect(body?.title.stringKey == "app_welcomeTileBody1")
        #expect(body?.title.value == "You can use this app to prove your identity to access some government services.")
        
        #expect(viewModel.backgroundColour == DesignSystem.Color.Backgrounds.card)
        #expect(!viewModel.showShadow)
        #expect(viewModel.dismissAction == nil)
    }
    
    @Test
    func test_purposeTileCell_viewModel() throws {
        let servicesTile = sut.tableView(
            try sut.tableView,
            cellForRowAt: IndexPath(row: 0, section: 1)
        ) as? ContentTileCell
        let viewModel = try #require(servicesTile?.viewModel)

        let title = viewModel.contentItems.first as? GDSTextViewModel
        #expect(title?.title.stringKey == "app_appPurposeTileHeader")
        #expect(title?.title.value == "How to prove your identity")
        
        let body = viewModel.contentItems.last as? GDSTextViewModel
        #expect(body?.title.stringKey == "app_appPurposeTileBody1")
        #expect(body?.title.variableKeys == ["app_nameString"])
        // swiftlint:disable:next line_length
        #expect(body?.title.value == "If you need to prove your identity with GOV.UK One Login to access a service, you'll be asked to open this app. It works by matching your face to your photo ID.")
        
        #expect(viewModel.backgroundColour == DesignSystem.Color.Backgrounds.card)
        #expect(!viewModel.showShadow)
        #expect(viewModel.dismissAction == nil)
    }
    
    @Test
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
        #expect(!idCell.isHidden)
        #expect((idCell as? ContentTileCell) == nil)
        #expect(!welcomeCell.isHidden)
        #expect((welcomeCell as? ContentTileCell) != nil)
        #expect(!purposeCell.isHidden)
        #expect((purposeCell as? ContentTileCell) != nil)
    }
    
    @Test
    func test_viewDidAppear() {
        #expect(mockAnalyticsService.screenViews.count == 0)
        sut.beginAppearanceTransition(true, animated: false)
        sut.endAppearanceTransition()
        #expect(mockAnalyticsService.screenViews.count == 1)
        let screen = ScreenView(id: HomeAnalyticsScreenID.homeScreen.rawValue,
                                screen: HomeAnalyticsScreen.homeScreen,
                                titleKey: "app_homeTitle")
        #expect(mockAnalyticsService.screenViews as? [ScreenView] == [screen])
        #expect(mockAnalyticsService.screenParamsLogged == screen.parameters)
        #expect(mockAnalyticsService.additionalParameters[OLTaxonomyKey.level2] as? String == OLTaxonomyValue.home)
        #expect(mockAnalyticsService.additionalParameters[OLTaxonomyKey.level3] as? String == OLTaxonomyValue.undefined)
    }
}

extension HomeViewController {
    var tableView: UITableView {
        get throws {
            try #require(view[child: "home-table-view"])
        }
    }
    
    var headerImage: UIImageView {
        get throws {
            try #require(view[child: "home-header-image"])
        }
    }
}
