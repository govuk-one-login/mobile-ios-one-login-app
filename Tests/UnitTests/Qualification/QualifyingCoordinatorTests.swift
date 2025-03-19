import Coordination
import GDSCommon
import Networking
@testable import OneLogin
import XCTest

final class QualifyingCoordinatorTests: XCTestCase {
    private var sessionManager: MockSessionManager!
    private var networkClient: NetworkClient!
    private var qualifyingService: MockQualifyingService!
    private var analyticsCenter: MockAnalyticsCenter!
    private var window: UIWindow!
    
    private var sut: QualifyingCoordinator!
    
    @MainActor
    override func setUp() {
        super.setUp()
        
        sessionManager = MockSessionManager()
        networkClient = NetworkClient()
        qualifyingService = MockQualifyingService()
        analyticsCenter = MockAnalyticsCenter(
            analyticsService: MockAnalyticsService(),
            analyticsPreferenceStore: MockAnalyticsPreferenceStore()
        )
        window = UIWindow()
        sut = QualifyingCoordinator(appWindow: window,
                                    analyticsCenter: analyticsCenter,
                                    appQualifyingService: qualifyingService,
                                    sessionManager: sessionManager,
                                    networkClient: networkClient)
    }
    
    override func tearDown() {
        sessionManager = nil
        networkClient = nil
        qualifyingService = nil
        analyticsCenter = nil
        window = nil
        sut = nil
        
        super.tearDown()
    }
}

// MARK: - App State updates
extension QualifyingCoordinatorTests {
    @MainActor
    func test_start_displaysLoadingScreen() throws {
        // GIVEN I open the app
        sut.start()
        // THEN there should be no screen on the app window
        XCTAssertNil(window.rootViewController)
    }
    
    @MainActor
    func test_unconfirmedApp_remainsOnLoadingScreen() throws {
        // GIVEN I reopen the app
        // WHEN I have not yet received a result from `appInfo`
        sut.didChangeAppInfoState(state: .notChecked)
        // THEN there should be no screen on the app window
        XCTAssertNil(window.rootViewController)
    }
    
    @MainActor
    func test_appUnavailable_displaysAppUnavailableScreen() throws {
        // GIVEN I reopen the app
        // WHEN I receive an App Unavailable result from `appInfo`
        sut.didChangeAppInfoState(state: .unavailable)
        // THEN I am shown the App Unavailable screen
        let vc = try XCTUnwrap(
            window.rootViewController as? GDSInformationViewController
        )
        XCTAssertTrue(vc.viewModel is AppUnavailableViewModel)
    }
    
    @MainActor
    func test_outdatedApp_displaysUpdateAppScreen() throws {
        // GIVEN I reopen the app
        // WHEN I receive an App outdated result from `appInfo`
        sut.didChangeAppInfoState(state: .outdated)
        // THEN I am shown the Update Required screen
        let vc = try XCTUnwrap(
            window.rootViewController as? GDSInformationViewController
        )
        XCTAssertTrue(vc.viewModel is UpdateAppViewModel)
    }
}

// MARK: - User State updates
extension QualifyingCoordinatorTests {
    @MainActor
    func test_confirmedUser_displaysMainView() throws {
        // WHEN I authenticate as a valid user
        sut.didChangeUserState(state: .loggedIn)
        // THEN I am shown the Main View
        let tabManagerCoordinator = try XCTUnwrap(sut.childCoordinators
            .lazy
            .compactMap { $0 as? TabManagerCoordinator }
            .first)
        XCTAssertIdentical(window.rootViewController, tabManagerCoordinator.root)
    }
    
    @MainActor
    func test_unconfirmedUser_seesTheLoginScreen() throws {
        // WHEN I have no session
        sut.didChangeUserState(state: .notLoggedIn)
        // THEN I am shown the Login Coordinator
        let loginCoordinator = try XCTUnwrap(sut.childCoordinators
            .lazy
            .compactMap { $0 as? LoginCoordinator }
            .first)
        XCTAssertIdentical(window.rootViewController, loginCoordinator.root)
    }
    
    @MainActor
    func test_expiredUser_seesTheLoginScreen() throws {
        // WHEN my session has expired
        sut.didChangeUserState(state: .expired)
        // THEN I am shown the Login Coordinator
        let loginCoordinator = try XCTUnwrap(sut.childCoordinators
            .lazy
            .compactMap { $0 as? LoginCoordinator }
            .first)
        XCTAssertIdentical(window.rootViewController, loginCoordinator.root)
    }
    
    @MainActor
    func test_failedUser_seesTheUnableToLoginScreen() throws {
        // WHEN I fail to login
        enum MockLoginError: Error, LocalizedError {
            case failed
            
            var errorDescription: String? {
                "Unable to login"
            }
        }
        
        sut.didChangeUserState(state: .failed(MockLoginError.failed))
        // THEN I am shown the Login Error screen
        let vc = try XCTUnwrap(
            window.rootViewController as? GDSErrorViewController
        )
        let viewModel = try XCTUnwrap(vc.viewModel as? UnableToLoginErrorViewModel)
        XCTAssertEqual(viewModel.errorDescription, "Unable to login")
    }
    
    @MainActor
    func test_handleUniversalLink_Wallet() throws {
        // WHEN I open the app
        sut.start()
        // GIVEN I open the app with a wallet deeplink
        let deeplink = try XCTUnwrap(URL(string: "google.co.uk/wallet"))
        sut.handleUniversalLink(deeplink)
        // THEN the wallet deeplink should be stored
        XCTAssertEqual(sut.deeplink, deeplink)
        // GIVEN the user has authenticated
        sut.didChangeUserState(state: .loggedIn)
        // THEN the deeplink should be consumed
        waitForTruth(self.sut.deeplink == nil, timeout: 5)
    }
}
