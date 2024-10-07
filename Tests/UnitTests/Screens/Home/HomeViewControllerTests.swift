import GDSAnalytics
@testable import OneLogin
import XCTest

@MainActor
final class HomeViewControllerTests: XCTestCase {
    var mockAnalyticsService: MockAnalyticsService!
    var sut: HomeViewController!
    
    override func setUp() {
        super.setUp()
        
        mockAnalyticsService = MockAnalyticsService()
        sut = HomeViewController(analyticsService: mockAnalyticsService)
    }
    
    override func tearDown() {
        mockAnalyticsService = nil
        sut = nil
        
        super.tearDown()
    }
}

extension HomeViewControllerTests {
    func test_title_contents() throws {
        sut.beginAppearanceTransition(true, animated: false)
        sut.endAppearanceTransition()
        XCTAssertEqual(sut.navigationTitle.stringKey, "app_homeTitle")
    }
    
    func test_numberOfSections() {
        XCTAssertEqual(sut.numberOfSections(in: sut.tableView), 1)
    }
    
    func test_numbeOfRowsInSection() {
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 0), 1)
    }
    
    func test_contentTileCell_viewModel() {
        let servicesTile = sut.tableView(
            sut.tableView,
            cellForRowAt: IndexPath(row: 0, section: 0)
        ) as? ContentTileCell
        XCTAssertTrue(servicesTile?.viewModel is ServicesTileViewModel)
    }
    
    func test_viewDidAppear() throws {
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
