import XCTest

final class OneLoginStagingAppEnvironmentTests: XCTestCase {
    let sut = AppEnvironment.self
    
    func test_plistValues() {
        XCTAssertEqual(Bundle.main.bundleIdentifier, "uk.gov.onelogin.staging")
        XCTAssertEqual(Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String, "One Login - Staging")
        XCTAssertEqual(Bundle.main.infoDictionary?["MinimumOSVersion"] as? String, "15.0")
    }
    
    func test_appEnvironment_featureFlags() {
        // Feature Flags
        XCTAssertTrue(sut.walletVisibleViaDeepLink)
        XCTAssertTrue(sut.walletVisibleIfExists)
        XCTAssertTrue(sut.walletVisibleToAll)
    }
    
    func test_appEnvironment_helpers() {
        // Helpers
        XCTAssertEqual(sut.buildConfiguration, "Staging")
        XCTAssertEqual(sut.isLocaleWelsh, false)
        XCTAssertEqual(sut.localeString, "en")
    }
    
    func test_appEnvironment_stsURLs() {
        // STS
        XCTAssertEqual(sut.stsClientID, "ctQpngJQrFFCrppZtYQFFoklHaq")
        XCTAssertEqual(sut.stsBaseURLString, "token.staging.account.gov.uk")
        XCTAssertEqual(sut.stsBaseURL.absoluteString, "https://token.staging.account.gov.uk")
        XCTAssertEqual(sut.stsAuthorize.absoluteString, "https://token.staging.account.gov.uk/authorize")
        XCTAssertEqual(sut.stsToken.absoluteString, "https://token.staging.account.gov.uk/token")
        XCTAssertEqual(sut.stsHelloWorld.absoluteString, "https://hello-world.token.staging.account.gov.uk/hello-world")
        XCTAssertEqual(sut.jwksURL.absoluteString, "https://token.staging.account.gov.uk/.well-known/jwks.json")
    }
    
    func test_appEnvironment_mobileBEURLs() {
        // Mobile BE
        XCTAssertEqual(sut.mobileBaseURLString, "mobile.staging.account.gov.uk")
        XCTAssertEqual(sut.mobileBaseURL.absoluteString, "https://mobile.staging.account.gov.uk")
        XCTAssertEqual(sut.mobileRedirect.absoluteString, "https://mobile.staging.account.gov.uk/redirect")
        XCTAssertEqual(sut.appInfoURL.absoluteString, "https://mobile.staging.account.gov.uk/appInfo")
        XCTAssertEqual(sut.txma.absoluteString, "https://mobile.staging.account.gov.uk/txma-event")
    }
    
    func test_appEnvironment_idCheckURLs() {
        // ID Check
        XCTAssertEqual(sut.idCheckDomainURL.absoluteString, "https://review-b.staging.account.gov.uk")
        XCTAssertEqual(sut.idCheckBaseURL.absoluteString, "https://api-backend-api.review-b.staging.account.gov.uk")
        XCTAssertEqual(sut.idCheckAsyncBaseURL.absoluteString, "https://sessions.review-b-async.staging.account.gov.uk")
        XCTAssertEqual(sut.idCheckHandoffURL.absoluteString, "https://review-b.staging.account.gov.uk/dca/app/handoff?device=iphone")
        XCTAssertEqual(sut.readIDURLString, "https://readid-proxy.review-b-async.staging.account.gov.uk/odata/v1/ODataServlet/")
        XCTAssertEqual(sut.iProovURLString, "wss://gds.rp.secure.iproov.me/ws")
    }
    
    func test_appEnvironment_externalURLs() {
        // External
        XCTAssertEqual(sut.govURLString, "gov.uk")
        XCTAssertEqual(sut.yourServicesLink, "home.account.gov.uk")
        XCTAssertEqual(sut.externalBaseURLString, "signin.staging.account.gov.uk")
    }
    
    func test_appEnvironment_settingsURLs() {
        // Settings Page
        XCTAssertEqual(sut.manageAccountURL.absoluteString, "https://home.account.gov.uk/security")
        XCTAssertEqual(sut.govURL.absoluteString, "https://gov.uk")
        XCTAssertEqual(sut.govSupportURL.absoluteString, "https://home.staging.account.gov.uk")
        XCTAssertEqual(sut.appHelpURL.absoluteString, "https://gov.uk/guidance/proving-your-identity-with-the-govuk-one-login-app")
        XCTAssertEqual(sut.contactURL.absoluteString, "https://home.account.gov.uk/contact-gov-uk-one-login?lng=en")
        XCTAssertEqual(sut.privacyPolicyURL.absoluteString, "https://gov.uk/government/publications/govuk-one-login-privacy-notice")
        XCTAssertEqual(sut.accessibilityStatementURL.absoluteString, "https://gov.uk/one-login/app-accessibility")
    }
    
    func test_appEnvironment_appStoreURLs() {
        // App Store
        XCTAssertEqual(sut.appStoreURL.absoluteString, "https://apps.apple.com")
        XCTAssertEqual(sut.appStore.absoluteString, "https://apps.apple.com/app/gov-uk-one-login/id6737119425")
    }
}
