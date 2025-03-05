import XCTest

final class StagingAppEnvironmentTests: XCTestCase {
    func test_defaultEnvironment_retrieveFromPlist() throws {
        let sut = AppEnvironment.self
        XCTAssertEqual(Bundle.main.bundleIdentifier, "uk.gov.onelogin.staging")
        XCTAssertEqual(Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String, "One Login - Staging")
        XCTAssertEqual(sut.stsAuthorize.absoluteString, "https://token.staging.account.gov.uk/authorize")
        XCTAssertEqual(sut.stsToken.absoluteString, "https://token.staging.account.gov.uk/token")
        XCTAssertEqual(sut.privacyPolicyURL.absoluteString, "https://signin.account.gov.uk/privacy-notice?lng=en")
        XCTAssertEqual(sut.manageAccountURL.absoluteString, "https://gov.uk/using-your-gov-uk-one-login")
        XCTAssertEqual(sut.stsClientID, "ctQpngJQrFFCrppZtYQFFoklHaq")
        XCTAssertEqual(sut.mobileRedirect.absoluteString, "https://mobile.staging.account.gov.uk/redirect")
        XCTAssertEqual(sut.mobileBaseURL.absoluteString, "https://mobile.staging.account.gov.uk")
        XCTAssertEqual(sut.stsHelloWorld.absoluteString, "https://hello-world.token.staging.account.gov.uk/hello-world")
        XCTAssertEqual(sut.jwksURL.absoluteString, "https://token.staging.account.gov.uk/.well-known/jwks.json")
        XCTAssertEqual(sut.appInfoURL.absoluteString, "https://mobile.staging.account.gov.uk/appInfo")
        XCTAssertEqual(sut.appStoreURL.absoluteString, "https://apps.apple.com")
        XCTAssertEqual(sut.appStore.absoluteString, "https://apps.apple.com/gb.app.uk.gov.digital-identity")
        XCTAssertEqual(sut.yourServicesLink, "home.account.gov.uk")
        XCTAssertEqual(sut.walletCredentialIssuer.absoluteString, "https://example-credential-issuer.mobile.staging.account.gov.uk")
        XCTAssertFalse(sut.isLocaleWelsh)
        XCTAssertFalse(sut.walletVisibleToAll)
        XCTAssertFalse(sut.walletVisibleIfExists)
        XCTAssertFalse(sut.walletVisibleViaDeepLink)
        XCTAssertTrue(sut.criOrchestratorEnabled)
    }
}
