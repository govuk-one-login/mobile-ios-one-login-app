import GDSAnalytics
@testable import OneLogin
import Testing

@MainActor
struct SettingsTabViewModelTests {
    var mockAnalyticsService: MockAnalyticsService!
    var mockSessionManager: MockSessionManager!
    var mockUrlOpener: MockURLOpener!
    var sut: SettingsTabViewModel!
    
    init() {
        mockAnalyticsService = MockAnalyticsService()
        mockSessionManager = MockSessionManager()
        mockUrlOpener = MockURLOpener()
        sut = SettingsTabViewModel(analyticsService: mockAnalyticsService,
                                   userProvider: mockSessionManager,
                                   urlOpener: mockUrlOpener,
                                   openSignOutPage: {},
                                   openDeveloperMenu: {})
    }
}

extension SettingsTabViewModelTests {
    @Test
    func test_page() {
        #expect(sut.navigationTitle.stringKey == "app_settingsTitle")
        #expect(sut.rightBarButtonTitle == nil)
        #expect(sut.backButtonIsHidden)
        #expect(sut.backButtonTitle == nil)
        #expect(sut.didDismiss == nil)
    }
    
    @Test
    func test_didAppear() {
        #expect(mockAnalyticsService.screenViews.count == 0)
        sut.didAppear?.perform()
        #expect(mockAnalyticsService.screenViews.count == 1)
        let screen = ScreenView(id: SettingsAnalyticsScreenID.settingsScreen.rawValue,
                                screen: SettingsAnalyticsScreen.settingsScreen,
                                titleKey: "app_settingsTitle")
        #expect(mockAnalyticsService.screenViews as? [ScreenView] == [screen])
        #expect(mockAnalyticsService.screenParamsLogged == screen.parameters)
        #expect(mockAnalyticsService.additionalParameters[OLTaxonomyKey.level2] as? String == OLTaxonomyValue.settings)
        #expect(mockAnalyticsService.additionalParameters[OLTaxonomyKey.level3] as? String == OLTaxonomyValue.undefined)
    }
    
    @Test
    func test_openSignOutPage() {
        var didOpenSignOutPage: Bool = false
        let sut = SettingsTabViewModel(analyticsService: mockAnalyticsService,
                                   userProvider: mockSessionManager,
                                   urlOpener: mockUrlOpener,
                                   openSignOutPage: {
            didOpenSignOutPage = true
        }, openDeveloperMenu: {})
        #expect(!didOpenSignOutPage)
        sut.openSignOutPage()
        #expect(didOpenSignOutPage)
    }
    
    @Test
    func test_openDeveloperMenu() {
        var didOpenDeveloperMenu: Bool = false
        let sut = SettingsTabViewModel(analyticsService: mockAnalyticsService,
                                   userProvider: mockSessionManager,
                                   urlOpener: mockUrlOpener,
                                   openSignOutPage: {},
                                   openDeveloperMenu: {
            didOpenDeveloperMenu = true
        })
        #expect(!didOpenDeveloperMenu)
        sut.openDeveloperMenu()
        #expect(didOpenDeveloperMenu)
    }
}
