import GDSAnalytics
import GDSCommon
@testable import OneLogin
import Testing

@MainActor
struct AppIntegrityErrorViewModelTests {
    @Test func test_page() async throws {
        let mockAnalyticsService = MockAnalyticsService()
        let appIntegrityErrorViewModel = AppIntegrityErrorViewModel(analyticsService: mockAnalyticsService)

        #expect(appIntegrityErrorViewModel.image == .error)
        #expect(appIntegrityErrorViewModel.title.stringKey == "app_appIntegrityErrorTitle")
        #expect(appIntegrityErrorViewModel.title.value == "Sorry, there’s a problem")
        #expect(appIntegrityErrorViewModel.bodyContent.count == 2)
        #expect(appIntegrityErrorViewModel.buttonViewModels.isEmpty)
        #expect(appIntegrityErrorViewModel.rightBarButtonTitle == nil)
        #expect(appIntegrityErrorViewModel.backButtonIsHidden == true)
    }

    @Test func test_didAppear() async throws {
        let mockAnalyticsService = MockAnalyticsService()
        let appIntegrityErrorViewModel = AppIntegrityErrorViewModel(analyticsService: mockAnalyticsService)

        
        appIntegrityErrorViewModel.didAppear()

        #expect(mockAnalyticsService.screenViews.count == 1)
        
        let expectedScreenView = ErrorScreenView(id: ErrorAnalyticsScreenID.appIntegrityError.rawValue,
                                     screen: ErrorAnalyticsScreen.appIntegrityError,
                                     titleKey: "app_appIntegrityErrorTitle",
                                     reason: "app integrity error")
        
        #expect(mockAnalyticsService.screenViews.map { $0 as? ErrorScreenView } == [expectedScreenView])
        #expect(mockAnalyticsService.screenParamsLogged == expectedScreenView.parameters)
        #expect(mockAnalyticsService.additionalParameters[OLTaxonomyKey.level2].map { $0 as? String} == OLTaxonomyValue.system)
        #expect(mockAnalyticsService.additionalParameters[OLTaxonomyKey.level3].map { $0 as? String} == OLTaxonomyValue.undefined)
    }
}
