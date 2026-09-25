import Foundation
import Testing

struct OneLoginStagingAppEnvironmentTests {
    let sut = AppEnvironment.self
    
    @Test
    func test_plistValues() {
        #expect(Bundle.main.bundleIdentifier == "uk.gov.onelogin.staging")
        #expect(Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String == "One Login - Staging")
        #expect(Bundle.main.infoDictionary?["MinimumOSVersion"] as? String == "16.7")
    }
    
    @Test
    func test_appEnvironment_helpers() {
        // Helpers
        #expect(sut.buildConfiguration == "Staging")
        #expect(sut.isLocaleWelsh == false)
        #expect(sut.localeString == "en")
    }
    
    @Test
    func test_appEnvironment_stsURLs() {
        // STS
        #expect(sut.stsClientID == "ctQpngJQrFFCrppZtYQFFoklHaq")
        #expect(sut.stsBaseURLString == "token.staging.account.gov.uk")
        #expect(sut.stsBaseURL.absoluteString == "https://token.staging.account.gov.uk")
        #expect(sut.stsAuthorize.absoluteString == "https://token.staging.account.gov.uk/authorize")
        #expect(sut.stsToken.absoluteString == "https://token.staging.account.gov.uk/token")
        #expect(sut.stsHelloWorld.absoluteString == "https://hello-world.token.staging.account.gov.uk/hello-world")
        #expect(sut.jwksURL.absoluteString == "https://token.staging.account.gov.uk/.well-known/jwks.json")
    }
    
    @Test
    func test_appEnvironment_mobileBEURLs() {
        // Mobile BE
        #expect(sut.mobileBaseURLString == "mobile.staging.account.gov.uk")
        #expect(sut.mobileBaseURL.absoluteString == "https://mobile.staging.account.gov.uk")
        #expect(sut.mobileRedirect.absoluteString == "https://mobile.staging.account.gov.uk/redirect")
        #expect(sut.appInfoURL.absoluteString == "https://mobile.staging.account.gov.uk/appInfo")
        #expect(sut.txma.absoluteString == "https://mobile.staging.account.gov.uk/txma-event")
    }
    
    @Test
    func test_appEnvironment_idCheckURLs() {
        // ID Check
        #expect(sut.idCheckDomainURL.absoluteString == "https://review-b.staging.account.gov.uk")
        #expect(sut.idCheckBaseURL.absoluteString == "https://api-backend-api.review-b.staging.account.gov.uk")
        #expect(sut.idCheckAsyncBaseURL.absoluteString == "https://sessions.review-b-async.staging.account.gov.uk")
        #expect(sut.idCheckHandoffURL.absoluteString == "https://review-b.staging.account.gov.uk/dca/app/handoff?device=iphone")
        #expect(sut.readIDURLString == "https://readid-proxy.review-b-async.staging.account.gov.uk/odata/v1/ODataServlet/")
        #expect(sut.iProovURLString == "wss://gds.rp.secure.iproov.me/ws")
    }
    
    @Test
    func test_appEnvironment_externalURLs() {
        // External
        #expect(sut.govURLString == "gov.uk")
        #expect(sut.yourServicesLink == "home.account.gov.uk")
        #expect(sut.externalBaseURLString == "signin.staging.account.gov.uk")
    }
    
    @Test
    func test_appEnvironment_settingsURLs() {
        // Settings Page
        #expect(sut.manageAccountURL.absoluteString == "https://home.account.gov.uk/security")
        #expect(sut.govURL.absoluteString == "https://gov.uk")
        #expect(sut.govSupportURL.absoluteString == "https://home.staging.account.gov.uk")
        #expect(sut.appHelpURL.absoluteString == "https://gov.uk/guidance/proving-your-identity-with-the-govuk-one-login-app")
        #expect(sut.contactURL.absoluteString == "https://home.account.gov.uk/contact-gov-uk-one-login?lng=en")
        #expect(sut.privacyPolicyURL.absoluteString == "https://gov.uk/government/publications/govuk-one-login-privacy-notice")
        #expect(sut.accessibilityStatementURL.absoluteString == "https://gov.uk/one-login/app-accessibility")
    }
 
    @Test
    func test_appEnvironment_appStoreURLs() {
        // App Store
        #expect(sut.appStoreURL.absoluteString == "https://apps.apple.com")
        #expect(sut.appStore.absoluteString == "https://apps.apple.com/app/gov-uk-one-login/id6737119425")
    }
}
