import GDSAnalytics
@testable import OneLogin
import Testing
import UIKit

@MainActor
struct LocalAuthErrorViewModelTests {
    let sut: LocalAuthErrorViewModel
    let mockAnalyticsService = MockAnalyticsService()
    let mockLocalAuthService = MockLocalAuthManager()
    let urlOpener = MockURLOpener()

    init() {
        sut = LocalAuthErrorViewModel(urlOpener: urlOpener,
                                      analyticsService: mockAnalyticsService,
                                      localAuthType: mockLocalAuthService.type)
    }
}

extension LocalAuthErrorViewModelTests {
    @Test
    func test_pageVariables() {
        #expect(sut.image == .error)
        #expect(sut.title.stringKey == "app_localAuthManagerErrorTitle")
        #expect(sut.bodyContent.count == 2)
        #expect(sut.buttonViewModels.count == 1)
        #expect(sut.rightBarButtonTitle != nil)
        #expect(sut.backButtonIsHidden)
    }
    
    @Test
    func test_primaryButton_action() {
        #expect(sut.buttonViewModels[0].title.stringKey == "app_localAuthManagerErrorGoToSettingsButton")
        #expect(urlOpener.didOpenURL == false)
        sut.buttonViewModels[0].action()
        #expect(urlOpener.didOpenURL)
    }
}
