import XCTest

final class OneLoginIntegrationAppEnvironmentTests: XCTestCase {
    let sut = AppEnvironment.self
    
    func test_plistValues() {
        XCTAssertEqual(Bundle.main.bundleIdentifier, "uk.gov.onelogin.integration")
        XCTAssertEqual(Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String, "One Login - Integration")
        XCTAssertEqual(Bundle.main.infoDictionary?["MinimumOSVersion"] as? String, "15.0")
    }
    
    func test_appEnvironment_featureFlags() {
        // Feature Flags
        XCTAssertFalse(sut.walletVisibleViaDeepLink)
        XCTAssertFalse(sut.walletVisibleIfExists)
        XCTAssertFalse(sut.walletVisibleToAll)
    }
    
    func test_appEnvironment_helpers() {
        // Helpers
        XCTAssertEqual(sut.buildConfiguration, "Integration")
        XCTAssertEqual(sut.isLocaleWelsh, false)
        XCTAssertEqual(sut.localeString, "en")
    }
    
    func test_appEnvironment_stsURLs() {
        // STS
        XCTAssertEqual(sut.stsClientID, "3Do0FOcrpsXe-mMklRruPUWmjr8")
        XCTAssertEqual(sut.stsBaseURLString, "token.integration.account.gov.uk")
        XCTAssertEqual(sut.stsBaseURL.absoluteString, "https://token.integration.account.gov.uk")
        XCTAssertEqual(sut.stsAuthorize.absoluteString, "https://token.integration.account.gov.uk/authorize")
        XCTAssertEqual(sut.stsToken.absoluteString, "https://token.integration.account.gov.uk/token")
        XCTAssertEqual(sut.stsHelloWorld.absoluteString, "https://hello-world.token.integration.account.gov.uk/hello-world")
        XCTAssertEqual(sut.jwksURL.absoluteString, "https://token.integration.account.gov.uk/.well-known/jwks.json")
    }
    
    func test_appEnvironment_mobileBEURLs() {
        // Mobile BE
        XCTAssertEqual(sut.mobileBaseURLString, "mobile.integration.account.gov.uk")
        XCTAssertEqual(sut.mobileBaseURL.absoluteString, "https://mobile.integration.account.gov.uk")
        XCTAssertEqual(sut.mobileRedirect.absoluteString, "https://mobile.integration.account.gov.uk/redirect")
        XCTAssertEqual(sut.appInfoURL.absoluteString, "https://mobile.integration.account.gov.uk/appInfo")
        XCTAssertEqual(sut.txma.absoluteString, "https://mobile.integration.account.gov.uk/txma-event")
        XCTAssertEqual(sut.walletCredentialIssuer.absoluteString, "https://example-credential-issuer.mobile.integration.account.gov.uk")
    }
    
    func test_appEnvironment_idCheckURLs() {
        // ID Check
        XCTAssertEqual(sut.idCheckDomainURL.absoluteString, "https://review-b.integration.account.gov.uk")
        XCTAssertEqual(sut.idCheckBaseURL.absoluteString, "https://api-backend-api.review-b.integration.account.gov.uk")
        XCTAssertEqual(sut.idCheckAsyncBaseURL.absoluteString, "https://sessions.review-b-async.integration.account.gov.uk")
        XCTAssertEqual(sut.idCheckHandoffURL.absoluteString, "https://review-b.integration.account.gov.uk/dca/app/handoff?device=iphone")
        XCTAssertEqual(sut.readIDURLString, "https://readid-proxy.review-b-async.integration.account.gov.uk/odata/v1/ODataServlet/")
        XCTAssertEqual(sut.iProovURLString, "wss://gds.rp.secure.iproov.me/ws")
    }
    
    func test_appEnvironment_externalURLs() {
        // External
        XCTAssertEqual(sut.govURLString, "gov.uk")
        XCTAssertEqual(sut.yourServicesLink, "home.account.gov.uk")
        XCTAssertEqual(sut.externalBaseURLString, "signin.integration.account.gov.uk")
    }
    
    func test_appEnvironment_settingsURLs() {
        // Settings Page
        XCTAssertEqual(sut.manageAccountURL.absoluteString, "https://gov.uk/using-your-gov-uk-one-login")
        XCTAssertEqual(sut.govURL.absoluteString, "https://gov.uk")
        XCTAssertEqual(sut.govSupportURL.absoluteString, "https://home.integration.account.gov.uk")
        XCTAssertEqual(sut.manageAccountURLEnglish.absoluteString, "https://gov.uk/using-your-gov-uk-one-login")
        XCTAssertEqual(sut.manageAccountURLWelsh.absoluteString, "https://gov.uk/defnyddio-eich-gov-uk-one-login")
        XCTAssertEqual(sut.appHelpURL.absoluteString, "https://gov.uk/one-login/app-help?lng=en")
        XCTAssertEqual(sut.contactURL.absoluteString, "https://home.account.gov.uk/contact-gov-uk-one-login?lng=en")
        XCTAssertEqual(sut.privacyPolicyURL.absoluteString, "https://gov.uk/government/publications/govuk-one-login-privacy-notice")
        XCTAssertEqual(sut.accessibilityStatementURL.absoluteString, "https://gov.uk/one-login/app-accessibility")
    }
    
    func test_appEnvironment_appStoreURLs() {
        // App Store
        XCTAssertEqual(sut.appStoreURL.absoluteString, "https://apps.apple.com")
        XCTAssertEqual(sut.appStore.absoluteString, "https://apps.apple.com/gb.app.uk.gov.digital-identity")
    }
}
