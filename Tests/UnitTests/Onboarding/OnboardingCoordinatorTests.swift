import Authentication
import GDSCommon
@testable import OneLogin
import XCTest

@MainActor
final class OnboardingCoordinatorTests: XCTestCase {
    var navigationController: UINavigationController!
    var mockAnalyticsService: MockAnalyticsService!
    var mockLAContext: MockLAContext!
    var sut: OnboardingCoordinator!
    
    override func setUp() {
        super.setUp()
        
        navigationController = .init()
        mockAnalyticsService = MockAnalyticsService()
        mockLAContext = MockLAContext()
        sut = OnboardingCoordinator(root: navigationController,
                                    analyticsService: mockAnalyticsService,
                                    localAuth: mockLAContext)
    }
    
    override func tearDown() {
        navigationController = nil
        mockAnalyticsService = nil
        mockLAContext = nil
        sut = nil
        
        super.tearDown()
    }
}

extension OnboardingCoordinatorTests {
    func test_start_noDevicePasscodeSet() throws {
        mockLAContext.returnedFromEvaluatePolicy = false
        // WHEN the OnboardingCoordinator has shown the passcode guidance via start()
        sut.start()
        // THEN the view controller should be the information screen
        let vc = sut.root.topViewController as? GDSInformationViewController
        XCTAssertTrue(vc != nil)
        XCTAssertTrue(vc?.viewModel is PasscodeInformationViewModel)
    }
    
    func test_start_devicePasscodeSet() throws {
        // GIVEN device passcode is set
        mockLAContext.returnedFromEvaluatePolicy = true
        // WHEN the OnboardingCoordinator has shown the passcode guidance via start()
        sut.start()
        // THEN the view conttollrt should be the token screen
        let vc = sut.root.topViewController as? TokensViewController
        XCTAssertTrue(vc != nil)
    }
}
