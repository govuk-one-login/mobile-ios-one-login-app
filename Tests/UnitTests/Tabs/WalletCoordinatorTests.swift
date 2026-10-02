import DesignSystem
import GDSAnalytics
import Networking
@testable import OneLogin
import SecureStore
import Testing
import Wallet
import UIKit

@MainActor
struct WalletCoordinatorTests {
    var mockAnalyticsService: MockAnalyticsService!
    var mockSessionManager: MockSessionManager!
    var sut: WalletCoordinator!
    
    init() {
        mockAnalyticsService = MockAnalyticsService()
        mockSessionManager = MockSessionManager()
        mockSessionManager.walletStoreID = "12345"
        sut = WalletCoordinator(
            analyticsService: mockAnalyticsService,
            networkingService: NetworkClient(),
            sessionManager: mockSessionManager
        )
    }
    
    @Test
    func test_tabBarItem() {
        // WHEN the WalletCoordinator has started
        sut.start()
        // THEN the bar button item of the root is correctly configured
        let walletTab = UITabBarItem(title: "Documents",
                                     image: UIImage(systemName: "wallet.pass.fill"),
                                     tag: 1)
        #expect(sut.root.tabBarItem.title == walletTab.title)
        #expect(sut.root.tabBarItem.image == walletTab.image)
        #expect(sut.root.tabBarItem.tag == walletTab.tag)
    }
    
    func test_didBecomeSelected() {
        #expect(mockAnalyticsService.eventsLogged.count == 0)
        sut.didBecomeSelected()
        let event = IconEvent(textKey: "app_tabBarWallet")
        #expect(mockAnalyticsService.eventsLogged.count == 1)
        #expect(mockAnalyticsService.eventsLogged == [event.name.name])
        #expect(mockAnalyticsService.eventsParamsLogged == event.parameters)
        #expect(mockAnalyticsService.additionalParameters[OLTaxonomyKey.level2] as? String != nil)
        #expect(mockAnalyticsService.additionalParameters[OLTaxonomyKey.level3] as? String != nil)
    }
    
    func test_walletInitFailed() throws {
        mockSessionManager.walletStoreID = nil
        sut.start()
        
        #expect(sut.root.viewControllers.count == 1)
        let screen = try #require(sut.root.topViewController as? GDSScreen)
        // TODO: DCMAW-20468 update with new error screen
        #expect(screen.viewModel is UnrecoverableLoginErrorViewModel)
    }
}
