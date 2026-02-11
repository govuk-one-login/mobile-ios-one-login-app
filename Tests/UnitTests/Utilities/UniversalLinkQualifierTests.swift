@testable import OneLogin
import XCTest

final class UniversalLinkQualifierTests: XCTestCase {
    var sut = UniversalLinkQualifier.self
}

extension UniversalLinkQualifierTests {
    func test_loginUniversalLinkBaseRedirectURI() throws {
        let oneLoginRedirectUrl = URL(string: AppEnvironment.mobileRedirect.absoluteString + "?code=testCode")!
        let appRoute = sut.qualifyOneLoginUniversalLink(oneLoginRedirectUrl)
        if case let .login(url) = appRoute {
            XCTAssertEqual(oneLoginRedirectUrl, url)
        } else {
            XCTFail("Expected .login but got \(appRoute)")
        }
    }
    
    func test_loginUniversalLinkAlternateRedirectURI() throws {
        let oneLoginRedirectUrl = URL(string: "https://app.mobile.account.gov.uk/redirect?code=testCode")!
        let appRoute = sut.qualifyOneLoginUniversalLink(oneLoginRedirectUrl)
        
        let expectedRedirectUrl = URL(string: AppEnvironment.mobileRedirect.absoluteString + "?code=testCode")!
        if case let .login(url) = appRoute {
            XCTAssertEqual(expectedRedirectUrl, url)
        } else {
            XCTFail("Expected .login but got \(appRoute)")
        }
    }

    func test_walletUniversalLink_last() throws {
        let oneLoginWalletUrl = URL(string: "https://mobile.account.gov.uk/wallet?code=testCode")!
        let appRoute = sut.qualifyOneLoginUniversalLink(oneLoginWalletUrl)
        if case .wallet = appRoute {
            // success
        } else {
            XCTFail("Expected .wallet but got \(appRoute)")
        }
    }

    func test_walletUniversalLink_any() throws {
        let oneLoginWalletUrl = URL(string: "https://mobile.account.gov.uk/wallet/test/paths?code=testCode")!
        let appRoute = sut.qualifyOneLoginUniversalLink(oneLoginWalletUrl)
        if case .wallet = appRoute {
            // success
        } else {
            XCTFail("Expected .wallet but got \(appRoute)")
        }
    }
}
