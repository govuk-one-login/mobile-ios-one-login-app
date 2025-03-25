import GDSAnalytics
@testable import OneLogin
import XCTest

@MainActor
final class SettingsTabViewModelTests: XCTestCase {
    var mockAnalyticsService: MockAnalyticsService!
    var mockSessionManager: MockSessionManager!
    var sut: SettingsTabViewModel!
    
    var didOpenSignOutPage: Bool = false
    var didOpenDeveloperMenu: Bool = false
    
    override func setUp() {
        super.setUp()
        
        mockAnalyticsService = MockAnalyticsService()
        mockSessionManager = MockSessionManager()
        sut = SettingsTabViewModel(analyticsService: mockAnalyticsService,
                                   userProvider: mockSessionManager,
                                   openSignOutPage: {
            self.didOpenSignOutPage = true
        },
                                   openDeveloperMenu: {
            self.didOpenDeveloperMenu = true
        })
    }
    
    override func tearDown() {
        mockAnalyticsService = nil
        sut = nil
        
        didOpenDeveloperMenu = false
        didOpenSignOutPage = false
        
        super.tearDown()
    }
}

extension SettingsTabViewModelTests {
    func test_page() {
        XCTAssertEqual(sut.navigationTitle.stringKey, "app_settingsTitle")
        XCTAssertNil(sut.rightBarButtonTitle)
        XCTAssertTrue(sut.backButtonIsHidden)
    }
    
    func test_didAppear() {
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 0)
        sut.didAppear()
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 1)
        let screen = ScreenView(id: SettingsAnalyticsScreenID.settingsScreen.rawValue,
                                screen: SettingsAnalyticsScreen.settingsScreen,
                                titleKey: "app_settingsTitle")
        XCTAssertEqual(mockAnalyticsService.screensVisited, [screen.name])
        XCTAssertEqual(mockAnalyticsService.screenParamsLogged, screen.parameters)
        XCTAssertEqual(mockAnalyticsService.additionalParameters[OLTaxonomyKey.level2] as? String, OLTaxonomyValue.settings)
        XCTAssertEqual(mockAnalyticsService.additionalParameters[OLTaxonomyKey.level3] as? String, OLTaxonomyValue.undefined)
    }
    
    func test_openSignOutPage() {
        XCTAssertFalse(didOpenSignOutPage)
        sut.openSignOutPage()
        XCTAssertTrue(didOpenSignOutPage)
    }
    
    func test_openDeveloperMenu() {
        XCTAssertFalse(didOpenDeveloperMenu)
        sut.openDeveloperMenu()
        XCTAssertTrue(didOpenDeveloperMenu)
    }
}
