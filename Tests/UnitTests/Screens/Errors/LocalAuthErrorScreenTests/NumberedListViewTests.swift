import GDSAnalytics
@testable import OneLogin
import Testing
import UIKit

@MainActor
struct NumberedListViewTests {
    let sut = LocalAuthErrorBulletViewModel()
    let mockLocalAuth = MockLocalAuthManager()

    @Test
    func test_pageVariables() {
        #expect(sut.title?.stringKey == "app_localAuthManagerErrorBody3")
        #expect(sut.titleConfig == nil)
        #expect(sut.listItemStrings.count == 3)
        #expect(sut.listItemStrings[1].stringKey == "app_localAuthManagerErrorNumberedList2")
        #expect(sut.listItemStrings[2].stringKey == "app_localAuthManagerErrorNumberedList3")
    }
}
