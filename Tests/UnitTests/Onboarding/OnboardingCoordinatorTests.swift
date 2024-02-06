import Authentication
import GDSCommon
@testable import OneLogin
import XCTest

@MainActor
final class OnboardingCoordinatorTests: XCTestCase {
    var navigationController: UINavigationController!
    var mockAnalyticsService: MockAnalyticsService!
    var sut: OnboardingCoordinator!
    
    
    override func setUp() {
        super.setUp()
        
        navigationController = .init()
        mockAnalyticsService = MockAnalyticsService()
        sut = OnboardingCoordinator(root: navigationController,
                                    analyticsService: mockAnalyticsService)
    }
    
    override func tearDown() {
        navigationController = nil
        mockAnalyticsService = nil
        sut = nil
        
        super.tearDown()
    }
}

extension OnboardingCoordinatorTests {
    func test_start_passcodeInformationScreen() throws {
        // WHEN the OnboardingCoordinator has shown the passcode guidance via start()
        sut.start()
        // THEN the view controller should be the information screen
        let vc = sut.root.topViewController as? GDSInformationViewController
        XCTAssertTrue(vc != nil)
        XCTAssertTrue(vc?.viewModel is PasscodeInformationViewModel)
        // WHEN the button is tapped
        let passcodePrimaryButton: UIButton = try XCTUnwrap(vc?.view[child: "information-primary-button"])
        passcodePrimaryButton.sendActions(for: .touchUpInside)
    }
}
