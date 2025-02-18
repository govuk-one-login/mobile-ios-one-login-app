import Foundation
import MobilePlatformServices
import Networking
@testable import OneLogin
import XCTest

final class AppEnvironmentTests: XCTestCase {
    func test_appEnvironmentValues() throws {
        let sut = AppEnvironment.self
        XCTAssertEqual(sut.privacyPolicyURL.absoluteString, "https://signin.account.gov.uk/privacy-notice?lng=en")
        XCTAssertEqual(sut.manageAccountURL.absoluteString, "https://gov.uk/using-your-gov-uk-one-login")
        XCTAssertEqual(sut.appHelpURL.absoluteString, "https://gov.uk/one-login/app-help?lng=en")
        XCTAssertEqual(sut.contactURL.absoluteString, "https://home.account.gov.uk/contact-gov-uk-one-login?lng=en")
        XCTAssertEqual(sut.accessibilityStatementURL.absoluteString, "https://signin.account.gov.uk/accessibility-statement?lng=en")
        XCTAssertEqual(sut.mobileRedirect.absoluteString, "https://mobile.build.account.gov.uk/redirect")
        XCTAssertEqual(sut.mobileBaseURLString, "mobile.build.account.gov.uk")
        XCTAssertEqual(sut.mobileBaseURL.absoluteString, "https://mobile.build.account.gov.uk")
        XCTAssertEqual(sut.stsAuthorize.absoluteString, "https://token.build.account.gov.uk/authorize")
        XCTAssertEqual(sut.stsToken.absoluteString, "https://token.build.account.gov.uk/token")
        XCTAssertEqual(sut.stsHelloWorld.absoluteString, "https://hello-world.token.build.account.gov.uk/hello-world")
        XCTAssertEqual(sut.stsBaseURLString, "token.build.account.gov.uk")
        XCTAssertEqual(sut.stsBaseURL.absoluteString, "https://token.build.account.gov.uk")
        XCTAssertEqual(sut.jwksURL.absoluteString, "https://token.build.account.gov.uk/.well-known/jwks.json")
        XCTAssertEqual(sut.appInfoURL.absoluteString, "https://mobile.build.account.gov.uk/appInfo")
        XCTAssertEqual(sut.stsClientID, "bYrcuRVvnylvEgYSSbBjwXzHrwJ")
        XCTAssertEqual(sut.isLocaleWelsh, false)
        XCTAssertEqual(sut.appStoreURL.absoluteString, "https://apps.apple.com")
        XCTAssertEqual(sut.appStore.absoluteString, "https://apps.apple.com/gb.app.uk.gov.digital-identity")
        XCTAssertEqual(sut.yourServicesURL.absoluteString, "https://home.account.gov.uk/your-services?lng=en")
        XCTAssertEqual(sut.yourServicesLink, "home.account.gov.uk")
        XCTAssertEqual(sut.walletCredentialIssuer.absoluteString, "https://example-credential-issuer.mobile.build.account.gov.uk")
        XCTAssertFalse(sut.isLocaleWelsh)
        XCTAssertFalse(sut.walletVisibleToAll)
        XCTAssertFalse(sut.walletVisibleIfExists)
        XCTAssertFalse(sut.walletVisibleViaDeepLink)
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
