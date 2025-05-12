import XCTest

final class OneLoginReleaseAppEnvironmentTests: XCTestCase {
    let sut = AppEnvironment.self
    
    func test_plistValues() {
        XCTAssertEqual(Bundle.main.bundleIdentifier, "uk.gov.onelogin")
        XCTAssertEqual(Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String, "One Login")
        XCTAssertEqual(Bundle.main.infoDictionary?["MinimumOSVersion"] as? String, "15.0")
    }
    
    func test_appEnvironment_featureFlags() {
        // Feature Flags
        XCTAssertFalse(sut.walletVisibleViaDeepLink)
        XCTAssertFalse(sut.walletVisibleIfExists)
        XCTAssertFalse(sut.walletVisibleToAll)
        XCTAssertFalse(sut.criOrchestratorEnabled)
    }
    
    func test_appEnvironment_helpers() {
        // Helpers
        XCTAssertEqual(sut.buildConfiguration, "Release")
        XCTAssertEqual(sut.isLocaleWelsh, false)
        XCTAssertEqual(sut.localeString, "en")
    }
    
    func test_appEnvironment_stsURLs() {
        // STS
        XCTAssertEqual(sut.stsClientID, "jHwDQGcnjorxfUtBvGwrGMjYrmQ")
        XCTAssertEqual(sut.stsBaseURLString, "token.account.gov.uk")
        XCTAssertEqual(sut.stsBaseURL.absoluteString, "https://token.account.gov.uk")
        XCTAssertEqual(sut.stsAuthorize.absoluteString, "https://token.account.gov.uk/authorize")
        XCTAssertEqual(sut.stsToken.absoluteString, "https://token.account.gov.uk/token")
        XCTAssertEqual(sut.stsHelloWorld.absoluteString, "https://hello-world.token.account.gov.uk/hello-world")
        XCTAssertEqual(sut.jwksURL.absoluteString, "https://token.account.gov.uk/.well-known/jwks.json")
    }
    
    func test_appEnvironment_mobileBEURLs() {
        // Mobile BE
        XCTAssertEqual(sut.mobileBaseURLString, "mobile.account.gov.uk")
        XCTAssertEqual(sut.mobileBaseURL.absoluteString, "https://mobile.account.gov.uk")
        XCTAssertEqual(sut.mobileRedirect.absoluteString, "https://mobile.account.gov.uk/redirect")
        XCTAssertEqual(sut.appInfoURL.absoluteString, "https://mobile.account.gov.uk/appInfo")
        XCTAssertEqual(sut.txma.absoluteString, "https://mobile.account.gov.uk/txma-event")
        XCTAssertEqual(sut.walletCredentialIssuer.absoluteString, "https://example-credential-issuer.mobile.account.gov.uk")
    }
    
    func test_appEnvironment_idCheckURLs() {
        // ID Check
        XCTAssertEqual(sut.idCheckDomainURL.absoluteString, "https://review-b.account.gov.uk")
        XCTAssertEqual(sut.idCheckBaseURL.absoluteString, "https://api-backend-api.review-b.account.gov.uk")
        XCTAssertEqual(sut.idCheckAsyncBaseURL.absoluteString, "https://sessions.review-b-async.account.gov.uk")
        XCTAssertEqual(sut.idCheckHandoffURL.absoluteString, "https://review-b.account.gov.uk/dca/app/handoff?device=iphone")
        XCTAssertEqual(sut.readIDURLString, "https://readid-proxy.review-b-async.account.gov.uk/odata/v1/ODataServlet/")
        XCTAssertEqual(sut.iProovURLString, "wss://gds.rp.secure.iproov.me/ws")
    }
    
    func test_appEnvironment_externalURLs() {
        // External
        XCTAssertEqual(sut.govURLString, "gov.uk")
        XCTAssertEqual(sut.yourServicesLink, "home.account.gov.uk")
        XCTAssertEqual(sut.externalBaseURLString, "signin.account.gov.uk")
    }
    
    func test_appEnvironment_settingsURLs() {
        // Settings Page
        XCTAssertEqual(sut.manageAccountURL.absoluteString, "https://gov.uk/using-your-gov-uk-one-login")
        XCTAssertEqual(sut.govURL.absoluteString, "https://gov.uk")
        XCTAssertEqual(sut.govSupportURL.absoluteString, "https://home.account.gov.uk")
        XCTAssertEqual(sut.manageAccountURLEnglish.absoluteString, "https://gov.uk/using-your-gov-uk-one-login")
        XCTAssertEqual(sut.manageAccountURLWelsh.absoluteString, "https://gov.uk/defnyddio-eich-gov-uk-one-login")
        XCTAssertEqual(sut.appHelpURL.absoluteString, "https://gov.uk/one-login/app-help?lng=en")
        XCTAssertEqual(sut.contactURL.absoluteString, "https://home.account.gov.uk/contact-gov-uk-one-login?lng=en")
        XCTAssertEqual(sut.privacyPolicyURL.absoluteString, "https://signin.account.gov.uk/privacy-notice?lng=en")
        XCTAssertEqual(sut.accessibilityStatementURL.absoluteString, "https://signin.account.gov.uk/accessibility-statement?lng=en")
    }
    
    func test_appEnvironment_appStoreURLs() {
        // App Store
        XCTAssertEqual(sut.appStoreURL.absoluteString, "https://apps.apple.com")
        XCTAssertEqual(sut.appStore.absoluteString, "https://apps.apple.com/gb.app.uk.gov.digital-identity")
    }
}
