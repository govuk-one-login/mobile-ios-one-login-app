@testable import OneLogin
import Testing

struct AppEnvironmentTests {
    let sut = AppEnvironment.self
    
    @Test
    func test_appEnvironment_helpers() {
        // Helpers
        #expect(sut.buildConfiguration == "Debug")
        #expect(sut.isLocaleWelsh == false)
        #expect(sut.localeString == "en")
    }
    
    @Test
    func test_appEnvironment_stsURLs() {
        // STS
        #expect(sut.stsClientID == "bYrcuRVvnylvEgYSSbBjwXzHrwJ")
        #expect(sut.stsBaseURLString == "token.build.account.gov.uk")
        #expect(sut.stsBaseURL.absoluteString == "https://token.build.account.gov.uk")
        #expect(sut.stsAuthorize.absoluteString == "https://token.build.account.gov.uk/authorize")
        #expect(sut.stsToken.absoluteString == "https://token.build.account.gov.uk/token")
        #expect(sut.stsHelloWorld.absoluteString == "https://hello-world.token.build.account.gov.uk/hello-world")
        #expect(sut.jwksURL.absoluteString == "https://token.build.account.gov.uk/.well-known/jwks.json")
    }
    
    @Test
    func test_appEnvironment_mobileBEURLs() {
        // Mobile BE
        #expect(sut.mobileBaseURLString == "mobile.build.account.gov.uk")
        #expect(sut.mobileBaseURL.absoluteString == "https://mobile.build.account.gov.uk")
        #expect(sut.mobileRedirect.absoluteString == "https://mobile.build.account.gov.uk/redirect")
        #expect(sut.appInfoURL.absoluteString == "https://mobile.build.account.gov.uk/appInfo")
        #expect(sut.txma.absoluteString == "https://mobile.build.account.gov.uk/txma-event")
    }
    
    @Test
    func test_appEnvironment_idCheckURLs() {
        // ID Check
        #expect(sut.idCheckDomainURL.absoluteString == "https://review-b.build.account.gov.uk")
        #expect(sut.idCheckBaseURL.absoluteString == "https://api-backend-api.review-b.build.account.gov.uk")
        #expect(sut.idCheckAsyncBaseURL.absoluteString == "https://sessions.review-b-async.build.account.gov.uk")
        #expect(sut.idCheckHandoffURL.absoluteString == "https://review-b.build.account.gov.uk/dca/app/handoff?device=iphone")
        #expect(sut.readIDURLString == "https://readid-proxy.review-b-async.build.account.gov.uk/odata/v1/ODataServlet/")
        #expect(sut.iProovURLString == "wss://gds.rp.secure.iproov.me/ws")
    }
    
    @Test
    func test_appEnvironment_externalURLs() {
        // External
        #expect(sut.govURLString == "gov.uk")
        #expect(sut.yourServicesLink == "home.account.gov.uk")
        #expect(sut.externalBaseURLString == "signin.build.account.gov.uk")
    }
    
    @Test
    func test_appEnvironment_settingsURLs() {
        // Settings Page
        #expect(sut.manageAccountURL.absoluteString == "https://home.account.gov.uk/security")
        #expect(sut.govURL.absoluteString == "https://gov.uk")
        #expect(sut.govSupportURL.absoluteString == "https://home.build.account.gov.uk")
        #expect(sut.appHelpURL.absoluteString == "https://gov.uk/guidance/proving-your-identity-with-the-govuk-one-login-app")
        #expect(sut.contactURL.absoluteString == "https://home.account.gov.uk/contact-gov-uk-one-login?lng=en")
        #expect(sut.privacyPolicyURL.absoluteString == "https://gov.uk/government/publications/govuk-one-login-privacy-notice")
        #expect(sut.accessibilityStatementURL.absoluteString == "https://gov.uk/one-login/app-accessibility")
        #expect(sut.govSignInURL.absoluteString == "https://gov.uk/sign-in")
    }
    
    @Test
    func test_appEnvironment_appStoreURLs() {
        // App Store
        #expect(sut.appStoreURL.absoluteString == "https://apps.apple.com")
        #expect(sut.appStore.absoluteString == "https://apps.apple.com/app/gov-uk-one-login/id6737119425")
    }
    
    @Test
    func test_releaseFlags() {
        // GIVEN no release flags from AppInfo end point
        // pass in release flags to enviroment
        
        AppEnvironment.updateFlags(
            releaseFlags: ["test1": true, "test2": false],
            featureFlags: [:]
        )
        
        // THEN the flags are set in environment
        #expect(AppEnvironment.remoteReleaseFlags["test1"] as? Bool == true)
        #expect(AppEnvironment.remoteReleaseFlags["test2"] as? Bool == false)
        
        #expect(AppEnvironment.remoteReleaseFlags["shouldBeNil"] as? Bool == nil)
        
        // WHEN updated to remove release flags from enviroment
        AppEnvironment.updateFlags(
            releaseFlags: [:],
            featureFlags: [:]
        )
        
        // THEN the release flags are unset in the environment
        #expect(AppEnvironment.remoteReleaseFlags["test1"] as? Bool == nil)
        #expect(AppEnvironment.remoteReleaseFlags["test2"] as? Bool == nil)
    }
}
