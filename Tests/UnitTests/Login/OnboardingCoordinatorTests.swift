import DesignSystem
@testable import OneLogin
import Testing
import UIKit

@MainActor
struct OnboardingCoordinatorTests {
    var mockAnalyticsPreferenceStore: MockAnalyticsPreferenceStore!
    var mockURLOpener: MockURLOpener!
    var sut: OnboardingCoordinator!
    
    init() {
        mockAnalyticsPreferenceStore = MockAnalyticsPreferenceStore()
        mockURLOpener = MockURLOpener()
        sut = OnboardingCoordinator(analyticsPreferenceStore: mockAnalyticsPreferenceStore,
                                    urlOpener: mockURLOpener)
    }
}

extension OnboardingCoordinatorTests {
    @Test
    func test_acceptAnalyticsPermissions() {
        // WHEN the OnboardingCoordinator is started
        sut.start()
        // THEN the 'analytics preference' screen is shown
        let vc = sut.root.topViewController as? GDSScreen
        let viewModel = vc?.viewModel as? AnalyticsPreferenceViewModel
        #expect(viewModel != nil)
        #expect(sut.root.isModalInPresentation)
        // WHEN the Allow button is tapped is started
        let acceptPermissionsButton = viewModel?.movableFooter.first as? GDSButtonViewModel
        acceptPermissionsButton?.buttonAction.perform()
        // THEN the analyticsPreferenceStore's hasAcceptedAnalytics value is updated to true
        #expect(mockAnalyticsPreferenceStore.hasAcceptedAnalytics ?? false)
    }

    @Test
    func test_declineAnalyticsPermissions() {
        // WHEN the OnboardingCoordinator is started
        sut.start()
        // THEN the 'analytics preference' screen is shown
        let vc = sut.root.topViewController as? GDSScreen
        let viewModel = vc?.viewModel as? AnalyticsPreferenceViewModel
        #expect(viewModel != nil)
        // WHEN the Disallow button is tapped is started
        let declinePermissionsButton = viewModel?.movableFooter[1] as? GDSButtonViewModel
        declinePermissionsButton?.buttonAction.perform()
        // THEN the analyticsPreferenceStore's hasAcceptedAnalytics value is updated to false
        #expect(!(mockAnalyticsPreferenceStore.hasAcceptedAnalytics ?? true))
    }
    
    @Test
    func test_openPrivacyPolicyURL() {
        // WHEN the OnboardingCoordinator is started
        sut.start()
        // THEN the 'analytics preference' screen is shown
        let vc = sut.root.topViewController as? GDSScreen
        let viewModel = vc?.viewModel as? AnalyticsPreferenceViewModel
        #expect(viewModel != nil)
        // WHEN the Privacy Policy button is tapped is started
        let privacyPolicyButton = viewModel?.body[2] as? GDSButtonViewModel
        privacyPolicyButton?.buttonAction.perform()
        // THEN the mockURLOpener's didOpenURL property is updated to true
        #expect(mockURLOpener.didOpenURL)
    }
}
