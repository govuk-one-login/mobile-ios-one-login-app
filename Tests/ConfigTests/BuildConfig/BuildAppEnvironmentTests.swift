@testable import OneLogin
import XCTest

final class BuildAppEnvironmentTests: XCTestCase {
    func test_defaultEnvironment_retrieveFromPlist() throws {
        let sut = AppEnvironment.self
        XCTAssertEqual(sut.oneLoginAuthorize, URL(string: "https://auth-stub.mobile.build.account.gov.uk/authorize"))
        XCTAssertEqual(sut.stsAuthorize, URL(string: "https://token.build.account.gov.uk/authorize"))
        XCTAssertEqual(sut.oneLoginToken, URL(string: "https://mobile.build.account.gov.uk/token"))
        XCTAssertEqual(sut.stsToken, URL(string: "https://token.build.account.gov.uk/token"))
        XCTAssertEqual(sut.privacyPolicyURL, URL(string: "https://signin.account.gov.uk/privacy-notice?lng=en"))
        XCTAssertEqual(sut.manageAccountURL, URL(string: "https://signin.account.gov.uk/sign-in-or-create?lng=en"))
        XCTAssertEqual(sut.oneLoginClientID, "TEST_CLIENT_ID")
        XCTAssertEqual(sut.stsClientID, "bYrcuRVvnylvEgYSSbBjwXzHrwJ")
        XCTAssertEqual(sut.oneLoginRedirect, "https://mobile.build.account.gov.uk/redirect")
        XCTAssertEqual(sut.oneLoginBaseURL, "mobile.build.account.gov.uk")
        XCTAssertEqual(sut.stsHelloWorld, URL(string: "https://hello-world.token.build.account.gov.uk/hello-world"))
        XCTAssertEqual(sut.stsHelloWorldError, URL(string: "https://hello-world.token.build.account.gov.uk/hello-world/error"))
        XCTAssertEqual(sut.appStoreURL, URL(string: "https://apps.apple.com"))
        XCTAssertEqual(sut.appStore, URL(string: "https://apps.apple.com/gb.app.uk.gov.digital-identity"))
        XCTAssertTrue(sut.callingSTSEnabled)
        XCTAssertFalse(sut.isLocaleWelsh)
    }
}
