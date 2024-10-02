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
    private var walletAvailabilityService: MockWalletAvailabilityService!
    private var window: UIWindow!

    private var sut: QualifyingCoordinator!

    @MainActor
    override func setUp() {
        super.setUp()

        window = UIWindow()

        analyticsCenter = MockAnalyticsCenter(
            analyticsService: MockAnalyticsService(),
            analyticsPreferenceStore: MockAnalyticsPreferenceStore()
        )

        sessionManager = MockSessionManager()
        qualifyingService = MockQualifyingService()

        networkClient = NetworkClient()
        
        walletAvailabilityService = MockWalletAvailabilityService()

        sut = QualifyingCoordinator(window: window,
                                    analyticsCenter: analyticsCenter,
                                    appQualifyingService: qualifyingService,
                                    sessionManager: sessionManager,
                                    networkClient: networkClient,
                                    walletAvailibilityService: walletAvailabilityService)
    }

    override func tearDown() {
        sessionManager = nil
        networkClient = nil
        qualifyingService = nil
        analyticsCenter = nil
        walletAvailabilityService = nil
        window = nil

        super.tearDown()
    }
}
// MARK: - App State updates
extension QualifyingCoordinatorTests {
    @MainActor
    func test_start_displaysLoadingScreen() throws {
        // GIVEN I open the app
        sut.start()
        // THEN I am shown the loading screen
        _ = try XCTUnwrap(
            window.rootViewController as? UnlockScreenViewController
        )
    }

    @MainActor
    func test_unconfirmedApp_remainsOnLoadingScreen() throws {
        // GIVEN I reopen the app
        // WHEN I have not yet received a result from `appInfo`
        sut.didChangeAppInfoState(state: .notChecked)
        // THEN I remain on the loading screen
        _ = try XCTUnwrap(
            window.rootViewController as? UnlockScreenViewController
        )
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
        // GIVEN I reopen the app
        // WHEN I authenticate as a valid user
        sut.didChangeUserState(state: .loggedIn)
        // THEN I am shown the Main View
        let tabManagerCoordinator = try XCTUnwrap(sut.childCoordinators
            .compactMap { $0 as? TabManagerCoordinator }
            .first)
        XCTAssertIdentical(window.rootViewController, tabManagerCoordinator.root)
    }

    @MainActor
    func test_unconfirmedUser_seesTheLoginScreen() throws {
        // GIVEN I reopen the app
        // WHEN I have no session
        sut.didChangeUserState(state: .notLoggedIn)
        // THEN I am shown the Login Coordinator
        let loginCoordinator = try XCTUnwrap(sut.childCoordinators
            .compactMap { $0 as? LoginCoordinator }
            .first)
        XCTAssertIdentical(window.rootViewController, loginCoordinator.root)
    }

    @MainActor
    func test_expiredUser_seesTheLoginScreen() throws {
        // GIVEN I reopen the app
        // WHEN my session has expired
        sut.didChangeUserState(state: .expired)
        // THEN I am shown the Login Coordinator
        let loginCoordinator = try XCTUnwrap(sut.childCoordinators
            .compactMap { $0 as? LoginCoordinator }
            .first)
        XCTAssertIdentical(window.rootViewController, loginCoordinator.root)
    }

    @MainActor
    func test_failedUser_seesTheUnableToLoginScreen() throws {
        // GIVEN I reopen the app
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
}
