import Foundation
import MobilePlatformServices
import Networking
@testable import OneLogin
import XCTest

final class AppEnvironmentTests: XCTestCase {
    func test_appEnvironmentValues() throws {
        let sut = AppEnvironment.self
        
        // Feature Flags
        XCTAssertFalse(sut.walletVisibleToAll)
        XCTAssertFalse(sut.walletVisibleIfExists)
        XCTAssertFalse(sut.walletVisibleViaDeepLink)
        
        // Helpers
        XCTAssertEqual(sut.buildConfiguration, "Debug")
        XCTAssertEqual(sut.isLocaleWelsh, false)
        XCTAssertEqual(sut.localeString, "en")
        
        // STS
        XCTAssertEqual(sut.stsClientID, "bYrcuRVvnylvEgYSSbBjwXzHrwJ")
        XCTAssertEqual(sut.stsBaseURLString, "token.build.account.gov.uk")
        XCTAssertEqual(sut.stsBaseURL.absoluteString, "https://token.build.account.gov.uk")
        XCTAssertEqual(sut.stsAuthorize.absoluteString, "https://token.build.account.gov.uk/authorize")
        XCTAssertEqual(sut.stsToken.absoluteString, "https://token.build.account.gov.uk/token")
        XCTAssertEqual(sut.stsHelloWorld.absoluteString, "https://hello-world.token.build.account.gov.uk/hello-world")
        XCTAssertEqual(sut.jwksURL.absoluteString, "https://token.build.account.gov.uk/.well-known/jwks.json")
        
        // Mobile BE
        XCTAssertEqual(sut.mobileBaseURLString, "mobile.build.account.gov.uk")
        XCTAssertEqual(sut.mobileBaseURL.absoluteString, "https://mobile.build.account.gov.uk")
        XCTAssertEqual(sut.mobileRedirect.absoluteString, "https://mobile.build.account.gov.uk/redirect")
        XCTAssertEqual(sut.appInfoURL.absoluteString, "https://mobile.build.account.gov.uk/appInfo")
        XCTAssertEqual(sut.txma.absoluteString, "https://mobile.build.account.gov.uk/txma-event")
        XCTAssertEqual(sut.walletCredentialIssuer.absoluteString, "https://example-credential-issuer.mobile.build.account.gov.uk")
        
        // ID Check
        XCTAssertEqual(sut.idCheckDomainURL.absoluteString, "https://review-b.build.account.gov.uk")
        XCTAssertEqual(sut.idCheckBaseURL.absoluteString, "https://api-backend-api.review-b.build.account.gov.uk")
        XCTAssertEqual(sut.idCheckAsyncBaseURL.absoluteString, "https://sessions.review-b-async.build.account.gov.uk")
        XCTAssertEqual(sut.idCheckHandoffURL.absoluteString, "https://review-b.build.account.gov.uk/dca/app/handoff?device=iphone")
        XCTAssertEqual(sut.readIDURLString, "https://readid.review-b.build.account.gov.uk/odata/v1/ODataServlet")
        XCTAssertEqual(sut.iProovURLString, "wss://gds.rp.secure.iproov.me/ws")
        
        // External
        XCTAssertEqual(sut.govURLString, "gov.uk")
        XCTAssertEqual(sut.yourServicesLink, "home.account.gov.uk")
        XCTAssertEqual(sut.externalBaseURLString, "signin.build.account.gov.uk")
        
        // Settings Page
        XCTAssertEqual(sut.manageAccountURL.absoluteString, "https://gov.uk/using-your-gov-uk-one-login")
        XCTAssertEqual(sut.govURL.absoluteString, "https://gov.uk")
        XCTAssertEqual(sut.govSupportURL.absoluteString, "https://home.build.account.gov.uk")
        XCTAssertEqual(sut.manageAccountURLEnglish.absoluteString, "https://gov.uk/using-your-gov-uk-one-login")
        XCTAssertEqual(sut.manageAccountURLWelsh.absoluteString, "https://gov.uk/defnyddio-eich-gov-uk-one-login")
        XCTAssertEqual(sut.appHelpURL.absoluteString, "https://gov.uk/one-login/app-help?lng=en")
        XCTAssertEqual(sut.contactURL.absoluteString, "https://home.account.gov.uk/contact-gov-uk-one-login?lng=en")
        XCTAssertEqual(sut.privacyPolicyURL.absoluteString, "https://signin.build.account.gov.uk/privacy-notice?lng=en")
        XCTAssertEqual(sut.accessibilityStatementURL.absoluteString, "https://signin.build.account.gov.uk/accessibility-statement?lng=en")
        
        // App Store
        XCTAssertEqual(sut.appStoreURL.absoluteString, "https://apps.apple.com")
        XCTAssertEqual(sut.appStore.absoluteString, "https://apps.apple.com/gb.app.uk.gov.digital-identity")
    }
    
    func test_releaseFlags() {
        // GIVEN no release flags from AppInfo end point
        // pass in release flags to enviroment
        
        AppEnvironment.updateFlags(
            releaseFlags: ["test1": true, "test2": false],
            featureFlags: [:]
        )
        
        // THEN the flags are set in environment
        XCTAssertEqual(AppEnvironment.remoteReleaseFlags["test1"] as? Bool, true)
        XCTAssertEqual(AppEnvironment.remoteReleaseFlags["test2"] as? Bool, false)
        
        XCTAssertNil(AppEnvironment.remoteReleaseFlags["shouldBeNil"] as? Bool)
        
        // WHEN updated to remove release flags from enviroment
        AppEnvironment.updateFlags(
            releaseFlags: [:],
            featureFlags: [:]
        )
        
        // THEN the release flags are unset in the environment
        XCTAssertNil(AppEnvironment.remoteReleaseFlags["test1"] as? Bool)
        XCTAssertNil(AppEnvironment.remoteReleaseFlags["test2"] as? Bool)
    }
}
