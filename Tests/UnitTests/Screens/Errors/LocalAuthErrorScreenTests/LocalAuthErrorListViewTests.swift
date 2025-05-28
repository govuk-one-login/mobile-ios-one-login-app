import GDSAnalytics
@testable import OneLogin
import Testing
import UIKit

@MainActor
struct LocalAuthErrorListViewModelTests {
    let sut: LocalAuthErrorListViewModel!
    let mockLocalAuth = MockLocalAuthManager()

    init() {
        sut = LocalAuthErrorListViewModel(localAuthType: mockLocalAuth.type)
    }

    @Test
    func test_pageVariables() {
        #expect(sut.title?.stringKey == "app_localAuthManagerErrorBody3")
        #expect(sut.titleConfig?.font == .body)
        #expect(sut.titleConfig?.isHeader == false)
        #expect(sut.listItemStrings.count == 3)
        #expect(sut.listItemStrings[0].stringKey == "app_localAuthManagerErrorNumberedList1TouchID")
        #expect(sut.listItemStrings[1].stringKey == "app_localAuthManagerErrorNumberedList2")
        #expect(sut.listItemStrings[2].stringKey == "app_localAuthManagerErrorNumberedList3")
        #expect(sut.listItemStrings[2].variableKeys == ["app_walletString"])
    }
}
