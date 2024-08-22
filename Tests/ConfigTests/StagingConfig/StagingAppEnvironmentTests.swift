@testable import OneLogin
import XCTest

final class StagingAppEnvironmentTests: XCTestCase {
    func test_defaultEnvironment_retrieveFromPlist() throws {
        let sut = AppEnvironment.self
        XCTAssertEqual(sut.oneLoginAuthorize, URL(string: "https://oidc.integration.account.gov.uk/authorize"))
        XCTAssertEqual(sut.stsAuthorize, URL(string: "https://token.staging.account.gov.uk/authorize"))
        XCTAssertEqual(sut.oneLoginToken, URL(string: "https://mobile.staging.account.gov.uk/token"))
        XCTAssertEqual(sut.stsToken, URL(string: "https://token.staging.account.gov.uk/token"))
        XCTAssertEqual(sut.privacyPolicyURL, URL(string: "https://signin.account.gov.uk/privacy-notice?lng=en"))
        XCTAssertEqual(sut.manageAccountURL, URL(string: "https://signin.account.gov.uk/sign-in-or-create?lng=en"))
        XCTAssertEqual(sut.oneLoginClientID, "sdJChz1oGajIz0O0tdPdh0CA2zW")
        XCTAssertEqual(sut.stsClientID, "ctQpngJQrFFCrppZtYQFFoklHaq")
        XCTAssertEqual(sut.oneLoginRedirect, "https://mobile.staging.account.gov.uk/redirect")
        XCTAssertEqual(sut.oneLoginBaseURL, "mobile.staging.account.gov.uk")
        XCTAssertEqual(sut.stsHelloWorld, URL(string: "https://hello-world.token.staging.account.gov.uk/hello-world"))
        XCTAssertEqual(sut.stsHelloWorldError, URL(string: "https://hello-world.token.staging.account.gov.uk/hello-world/error"))
        XCTAssertEqual(sut.appStoreURL, URL(string: "https://apps.apple.com"))
                XCTAssertEqual(sut.appStore, URL(string: "https://apps.apple.com/gb.app.uk.gov.digital-identity"))
        XCTAssertTrue(sut.callingSTSEnabled)
        XCTAssertFalse(sut.isLocaleWelsh)
    }
}
