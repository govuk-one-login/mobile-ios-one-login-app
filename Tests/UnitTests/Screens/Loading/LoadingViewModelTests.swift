import DesignSystem
import GDSAnalytics
@testable import OneLogin
import Testing

@MainActor
struct LoadingViewModelTests {
    let mockAnalyticsService = MockAnalyticsService()
    
    @Test
    func testScreen() {
        let sut = LoadingViewModel(analyticsService: mockAnalyticsService)
        let progressView = sut.body.first as? GDSProgressIndicatorViewModel
        #expect(progressView != nil)
    }
    
    @Test
    func test_didAppear() {
        let sut = LoadingViewModel(analyticsService: mockAnalyticsService)
        let vc = GDSScreen(viewModel: sut)
        
        #expect(mockAnalyticsService.screenViews.count == 0)
        vc.beginAppearanceTransition(true, animated: false)
        vc.endAppearanceTransition()
        #expect(mockAnalyticsService.screenViews.count == 1)
        
        let screen = ScreenView(id: IntroAnalyticsScreenID.loginLoading.rawValue,
                                screen: IntroAnalyticsScreen.loginLoading,
                                titleKey: "app_loadingBody")
        #expect(mockAnalyticsService.screenViews as? [ScreenView] == [screen])
        #expect(mockAnalyticsService.screenParamsLogged == screen.parameters)
    }
}
