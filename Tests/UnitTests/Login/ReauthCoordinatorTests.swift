import Authentication
import GDSAnalytics
import GDSCommon
@testable import OneLogin
import XCTest

@MainActor
final class ReauthCoordinatorTests: XCTestCase {
    var window: UIWindow!
    var mockAnalyticsService: MockAnalyticsService!
    var mockAuthenticatedSecureStore: MockSecureStoreService!
    var mockOpenSecureStore: MockSecureStoreService!
    var mockDefaultsStore: MockDefaultsStore!
    var mockUserStore: MockUserStore!
    var sut: ReauthCoordinator!
    
    override func setUp() {
        super.setUp()
        
        window = UIWindow()
        mockAnalyticsService = MockAnalyticsService()
        mockAuthenticatedSecureStore = MockSecureStoreService()
        mockOpenSecureStore = MockSecureStoreService()
        mockDefaultsStore = MockDefaultsStore()
        mockUserStore = MockUserStore(authenticatedStore: mockAuthenticatedSecureStore,
                                      openStore: mockOpenSecureStore,
                                      defaultsStore: mockDefaultsStore)
        sut = ReauthCoordinator(window: window,
                                analyticsService: mockAnalyticsService,
                                userStore: mockUserStore)
    }
    
    override func tearDown() {
        window = nil
        mockAnalyticsService = nil
        mockAuthenticatedSecureStore = nil
        mockOpenSecureStore = nil
        mockDefaultsStore = nil
        mockUserStore = nil
        sut = nil
        
        super.tearDown()
    }
    
    private enum AuthenticationError: Error {
        case generic
    }
}

extension ReauthCoordinatorTests {
    func test_start_showsSignOutWarningScreen() throws {
        // WHEN the ReauthCoordinator starts
        sut.start()
        // THEN the root view controller should be the sign out warning screen
        XCTAssertTrue(sut.root.topViewController is GDSErrorViewController)
        let errorVc = try XCTUnwrap(sut.root.topViewController as? GDSErrorViewController)
        XCTAssertTrue(errorVc.viewModel is SignOutWarningViewModel)
    }
    
    func test_didRegainFocus_fromAuthenticationCoordinator_succeeds() throws {
        let tokenResponse = try MockTokenResponse().getJSONData()
        TokenHolder.shared.tokenResponse = tokenResponse
        let authCoordinator = AuthenticationCoordinator(root: UINavigationController(),
                                                        analyticsService: mockAnalyticsService,
                                                        userStore: mockUserStore,
                                                        session: MockLoginSession())
        // GIVEN the ReauthCoordinator has started and set it's view controllers
        sut.start()
        let vc = try XCTUnwrap(sut.root.topViewController as? GDSErrorViewController)
        vc.loadView()
        // GIVEN the ReauthCoordinator regained focus from the AuthenticationCoordinator
        sut.didRegainFocus(fromChild: authCoordinator)
        // THEN the ReauthCoordinator should still have IntroViewController as it's top view controller
        XCTAssertEqual(mockDefaultsStore.savedData[.accessTokenExpiry] as? Date, tokenResponse.expiryDate)
        XCTAssertEqual(mockAuthenticatedSecureStore.savedItems[.accessToken], tokenResponse.accessToken)
        XCTAssertEqual(mockAuthenticatedSecureStore.savedItems[.idToken], tokenResponse.idToken)
    }
    
    func test_didRegainFocus_fromAuthenticationCoordinator_withError() throws {
        let authCoordinator = AuthenticationCoordinator(root: UINavigationController(),
                                                        analyticsService: mockAnalyticsService,
                                                        userStore: mockUserStore,
                                                        session: MockLoginSession())
        authCoordinator.authError = AuthenticationError.generic
        // GIVEN the ReauthCoordinator has started and set it's view controllers
        sut.start()
        let vc = try XCTUnwrap(sut.root.topViewController as? GDSErrorViewController)
        vc.loadView()
        // GIVEN the ReauthCoordinator regained focus from the AuthenticationCoordinator
        sut.didRegainFocus(fromChild: authCoordinator)
        // THEN the ReauthCoordinator should still have IntroViewController as it's top view controller
        XCTAssertTrue(sut.root.topViewController is GDSErrorViewController)
        let introButton: UIButton = try XCTUnwrap(vc.view[child: "error-primary-button"])
        XCTAssertTrue(introButton.isEnabled)
    }
}
