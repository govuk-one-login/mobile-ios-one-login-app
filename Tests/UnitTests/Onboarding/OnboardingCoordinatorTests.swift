import GDSCommon
@testable import OneLogin
import XCTest

@MainActor
final class OnboardingCoordinatorTests: XCTestCase {
    var mockAnalyticsService: MockAnalyticsService!
    var mockAnalyticsPreferenceStore: MockAnalyticsPreferenceStore!
    var sut: OnboardingCoordinator!
    
    override func setUp() {
        super.setUp()
        
        mockAnalyticsService = MockAnalyticsService()
        mockAnalyticsPreferenceStore = MockAnalyticsPreferenceStore()
        sut = OnboardingCoordinator(analyticsService: mockAnalyticsService,
                                    analyticsPreferenceStore: mockAnalyticsPreferenceStore)
    }
    
    override func tearDown() {
        mockAnalyticsService = nil
        mockAnalyticsPreferenceStore = nil
        sut = nil
        
        super.tearDown()
    }
}

extension OnboardingCoordinatorTests {
    func test_acceptAnalyticsPermissions() throws {
        sut.start()
        let vc = try XCTUnwrap(sut.root.topViewController as? ModalInfoViewController)
        XCTAssertTrue(vc.viewModel is AnalyticsPreferenceViewModel)
        let acceptPermissionsButton: UIButton = try XCTUnwrap(vc.view[child: "modal-info-primary-button"])
        acceptPermissionsButton.sendActions(for: .touchUpInside)
        XCTAssertTrue(try XCTUnwrap(mockAnalyticsPreferenceStore.hasAcceptedAnalytics))
    }

    func test_declineAnalyticsPermissions() throws {
        sut.start()
        let vc = try XCTUnwrap(sut.root.topViewController as? ModalInfoViewController)
        XCTAssertTrue(vc.viewModel is AnalyticsPreferenceViewModel)
        let declinePermissionsButton: UIButton = try XCTUnwrap(vc.view[child: "modal-info-secondary-button"])
        declinePermissionsButton.sendActions(for: .touchUpInside)
        XCTAssertFalse(try XCTUnwrap(mockAnalyticsPreferenceStore.hasAcceptedAnalytics))
    }
}
