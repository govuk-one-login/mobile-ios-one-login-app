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
    func test_start_noDeviceLocalAuthSet() throws {
        mockLAContext.returnedFromEvaluatePolicyForAuthentication = false
        mockMainCoordinator.tokens = try MockTokenResponse().getJSONData()
        // WHEN the OnboardingCoordinator has shown the local auth guidance via start()
        mockMainCoordinator.openChildInline(sut)
        // THEN the view controller should be the information screen
        waitForTruth(self.navigationController.viewControllers.count == 1, timeout: 2)
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSInformationViewController)
        XCTAssertTrue(vc.viewModel is PasscodeInformationViewModel)
        // WHEN the button on the enrolment screen is tapped
        let enrolmentPrimaryButton: UIButton = try XCTUnwrap(vc.view[child: "information-primary-button"])
        enrolmentPrimaryButton.sendActions(for: .touchUpInside)
        // THEN user is taken to the tokens screen
        waitForTruth(self.navigationController.viewControllers.count == 2, timeout: 2)
        XCTAssertTrue(navigationController.topViewController is TokensViewController)
    }
    
    func test_start_deviceLocalAuthSet_passcode() throws {
        mockLAContext.returnedFromEvaluatePolicyForAuthentication = true
        mockMainCoordinator.tokens = try MockTokenResponse().getJSONData()
        // GIVEN device passcode is set
        // WHEN the OnboardingCoordinator has shown the local auth guidance via start()
        mockMainCoordinator.openChildInline(sut)
        // THEN the view controller should be the token screen
        waitForTruth(self.navigationController.viewControllers.count == 1, timeout: 2)
        XCTAssertTrue(navigationController.topViewController is TokensViewController)
    }
    
    func test_start_deviceLocalAuthSet_touchID_primaryButton() throws {
        mockLAContext.returnedFromEvaluatePolicyForBiometrics = true
        mockMainCoordinator.tokens = try MockTokenResponse().getJSONData()
        // GIVEN device passcode is set
        // WHEN the OnboardingCoordinator has shown the local auth guidance via start()
        mockMainCoordinator.openChildInline(sut)
        // THEN the view controller should be the token screen
        waitForTruth(self.navigationController.viewControllers.count == 1, timeout: 2)
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSInformationViewController)
        XCTAssertTrue(vc.viewModel is TouchIDEnrollmentViewModel)
        // WHEN the button on the enrolment screen is tapped
        let enrolmentPrimaryButton: UIButton = try XCTUnwrap(vc.view[child: "information-primary-button"])
        enrolmentPrimaryButton.sendActions(for: .touchUpInside)
        // THEN user is taken to the tokens screen
        waitForTruth(self.navigationController.viewControllers.count == 2, timeout: 2)
        XCTAssertTrue(navigationController.topViewController is TokensViewController)
    }
    
    func test_start_deviceLocalAuthSet_touchID_secondaryButton() throws {
        mockLAContext.returnedFromEvaluatePolicyForBiometrics = true
        mockMainCoordinator.tokens = try MockTokenResponse().getJSONData()
        // GIVEN device passcode is set
        // WHEN the OnboardingCoordinator has shown the local auth guidance via start()
        mockMainCoordinator.openChildInline(sut)
        // THEN the view controller should be the token screen
        waitForTruth(self.navigationController.viewControllers.count == 1, timeout: 2)
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSInformationViewController)
        XCTAssertTrue(vc.viewModel is TouchIDEnrollmentViewModel)
        // WHEN the button on the enrolment screen is tapped
        let enrolmentSecondaryButton: UIButton = try XCTUnwrap(vc.view[child: "information-secondary-button"])
        enrolmentSecondaryButton.sendActions(for: .touchUpInside)
        // THEN user is taken to the tokens screen
        waitForTruth(self.navigationController.viewControllers.count == 2, timeout: 2)
        XCTAssertTrue(navigationController.topViewController is TokensViewController)
    }
    
    func test_start_deviceLocalAuthSet_faceID_primaryButton() throws {
        mockLAContext.returnedFromEvaluatePolicyForBiometrics = true
        mockMainCoordinator.tokens = try MockTokenResponse().getJSONData()
        mockLAContext.biometryType = .faceID
        // GIVEN device passcode is set
        // WHEN the OnboardingCoordinator has shown the local auth guidance via start()
        mockMainCoordinator.openChildInline(sut)
        // THEN the view controller should be the token screen
        waitForTruth(self.navigationController.viewControllers.count == 1, timeout: 2)
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSInformationViewController)
        XCTAssertTrue(vc.viewModel is FaceIDEnrollmentViewModel)
        // WHEN the button on the enrolment screen is tapped
        let enrolmentPrimaryButton: UIButton = try XCTUnwrap(vc.view[child: "information-primary-button"])
        enrolmentPrimaryButton.sendActions(for: .touchUpInside)
        // THEN user is taken to the tokens screen
        waitForTruth(self.navigationController.viewControllers.count == 2, timeout: 2)
        XCTAssertTrue(navigationController.topViewController is TokensViewController)
    }
    
    func test_start_deviceLocalAuthSet_faceID_secondaryButton() throws {
        mockLAContext.returnedFromEvaluatePolicyForBiometrics = true
        mockMainCoordinator.tokens = try MockTokenResponse().getJSONData()
        mockLAContext.biometryType = .faceID
        // GIVEN device passcode is set
        // WHEN the OnboardingCoordinator has shown the local auth guidance via start()
        mockMainCoordinator.openChildInline(sut)
        // THEN the view controller should be the token screen
        waitForTruth(self.navigationController.viewControllers.count == 1, timeout: 2)
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSInformationViewController)
        XCTAssertTrue(vc.viewModel is FaceIDEnrollmentViewModel)
        // WHEN the button on the enrolment screen is tapped
        let enrolmentSecondaryButton: UIButton = try XCTUnwrap(vc.view[child: "information-secondary-button"])
        enrolmentSecondaryButton.sendActions(for: .touchUpInside)
        // THEN user is taken to the tokens screen
        waitForTruth(self.navigationController.viewControllers.count == 2, timeout: 2)
        XCTAssertTrue(navigationController.topViewController is TokensViewController)
    }
}
