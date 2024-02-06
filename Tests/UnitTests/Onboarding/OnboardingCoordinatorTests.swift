import Authentication
import GDSCommon
@testable import OneLogin
import XCTest

@MainActor
final class OnboardingCoordinatorTests: XCTestCase {
    var window: UIWindow!
    var navigationController: UINavigationController!
    var mockAnalyticsService: MockAnalyticsService!
    var mockLAContext: MockLAContext!
    var mockMainCoordinator: MainCoordinator!
    var sut: OnboardingCoordinator!
    
    override func setUp() {
        super.setUp()
        
        window = .init()
        navigationController = .init()
        mockAnalyticsService = MockAnalyticsService()
        mockLAContext = MockLAContext()
        mockMainCoordinator = MainCoordinator(window: window, root: navigationController)
        sut = OnboardingCoordinator(root: navigationController,
                                    analyticsService: mockAnalyticsService,
                                    localAuth: mockLAContext)
    }
    
    override func tearDown() {
        navigationController = nil
        mockAnalyticsService = nil
        mockLAContext = nil
        mockMainCoordinator = nil
        sut = nil
        
        super.tearDown()
    }
}

extension OnboardingCoordinatorTests {
    func test_start_noDevicePasscodeSet() throws {
        mockLAContext.returnedFromEvaluatePolicy = false
        // WHEN the OnboardingCoordinator has shown the passcode guidance via start()
        mockMainCoordinator.openChildInline(sut)
        // THEN the view controller should be the information screen
        waitForTruth(self.navigationController.viewControllers.count == 1, timeout: 2)
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSInformationViewController)
        XCTAssertTrue(vc.viewModel is PasscodeInformationViewModel)
    }
    
    func test_start_devicePasscodeSet() throws {
        mockMainCoordinator.tokens = try MockTokenResponse().getJSONData()
        mockLAContext.returnedFromEvaluatePolicy = true
        // GIVEN device passcode is set
        // WHEN the OnboardingCoordinator has shown the passcode guidance via start()
        mockMainCoordinator.openChildInline(sut)
        // THEN the view controller should be the token screen
        waitForTruth(self.navigationController.viewControllers.count == 1, timeout: 2)
        XCTAssertTrue(navigationController.topViewController is TokensViewController)
    }
}
