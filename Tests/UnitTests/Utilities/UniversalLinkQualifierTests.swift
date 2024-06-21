@testable import OneLogin
import XCTest

final class UniversalLinkQualifierTests: XCTestCase {
    var sut = UniversalLinkQualifier.self
}

extension UniversalLinkQualifierTests {
    func test_loginUniversalLink() throws {
        let oneLoginRedirectUrl = URL(string: "https://mobile.account.gov.uk/redirect?code=testCode")!
        let appRoute = sut.qualifyOneLoginUniversalLink(oneLoginRedirectUrl)
        XCTAssertEqual(appRoute, AppRoute.login)
    }

    func test_walletUniversalLink_last() throws {
        let oneLoginWalletUrl = URL(string: "https://mobile.account.gov.uk/wallet?code=testCode")!
        let appRoute = sut.qualifyOneLoginUniversalLink(oneLoginWalletUrl)
        XCTAssertEqual(appRoute, AppRoute.wallet)
    }

    func test_walletUniversalLink_any() throws {
        let oneLoginWalletUrl = URL(string: "https://mobile.account.gov.uk/wallet/test/paths?code=testCode")!
        let appRoute = sut.qualifyOneLoginUniversalLink(oneLoginWalletUrl)
        XCTAssertEqual(appRoute, AppRoute.wallet)
    }
}
