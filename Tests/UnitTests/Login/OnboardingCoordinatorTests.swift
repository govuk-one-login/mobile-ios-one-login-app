import GDSCommon
@testable import OneLogin
import XCTest

@MainActor
final class OnboardingCoordinatorTests: XCTestCase {
    var mockAnalyticsService: MockAnalyticsService!
    var mockAnalyticsPreferenceStore: MockAnalyticsPreferenceStore!
    var mockURLOpener: MockURLOpener!
    var sut: OnboardingCoordinator!
    
    override func setUp() {
        super.setUp()
        
        mockAnalyticsService = MockAnalyticsService()
        mockAnalyticsPreferenceStore = MockAnalyticsPreferenceStore()
        mockURLOpener = MockURLOpener()
        sut = OnboardingCoordinator(analyticsPreferenceStore: mockAnalyticsPreferenceStore,
                                    urlOpener: mockURLOpener)
    }
    
    override func tearDown() {
        mockAnalyticsService = nil
        mockAnalyticsPreferenceStore = nil
        mockURLOpener = nil
        sut = nil
        
        super.tearDown()
    }
}

extension OnboardingCoordinatorTests {
    func test_acceptAnalyticsPermissions() throws {
        // WHEN the OnboardingCoordinator is started
        sut.start()
        // THEN the 'analytics preference' screen is shown
        let vc = try XCTUnwrap(sut.root.topViewController as? ModalInfoViewController)
        XCTAssertTrue(vc.viewModel is AnalyticsPreferenceViewModel)
        // WHEN the Allow button is tapped is started
        let acceptPermissionsButton: UIButton = try XCTUnwrap(vc.view[child: "modal-info-primary-button"])
        acceptPermissionsButton.sendActions(for: .touchUpInside)
        // THEN the analyticsPreferenceStore's hasAcceptedAnalytics value is updated to true
        XCTAssertTrue(try XCTUnwrap(mockAnalyticsPreferenceStore.hasAcceptedAnalytics))
    }

    func test_declineAnalyticsPermissions() throws {
        // WHEN the OnboardingCoordinator is started
        sut.start()
        // THEN the 'analytics preference' screen is shown
        let vc = try XCTUnwrap(sut.root.topViewController as? ModalInfoViewController)
        XCTAssertTrue(vc.viewModel is AnalyticsPreferenceViewModel)
        // WHEN the Disallow button is tapped is started
        let declinePermissionsButton: UIButton = try XCTUnwrap(vc.view[child: "modal-info-secondary-button"])
        declinePermissionsButton.sendActions(for: .touchUpInside)
        // THEN the analyticsPreferenceStore's hasAcceptedAnalytics value is updated to false
        XCTAssertFalse(try XCTUnwrap(mockAnalyticsPreferenceStore.hasAcceptedAnalytics))
    }
    
    func test_openPrivacyPolicyURL() throws {
        // WHEN the OnboardingCoordinator is started
        sut.start()
        // THEN the 'analytics preference' screen is shown
        let vc = try XCTUnwrap(sut.root.topViewController as? ModalInfoViewController)
        XCTAssertTrue(vc.viewModel is AnalyticsPreferenceViewModel)
        // WHEN the Privacy Policy button is tapped is started
        let privacyPolicyButton: UIButton = try XCTUnwrap(vc.view[child: "modal-info-text-button"])
        privacyPolicyButton.sendActions(for: .touchUpInside)
        // THEN the mockURLOpener's didOpenURL property is updated to true
        XCTAssertTrue(mockURLOpener.didOpenURL)
    }
}
