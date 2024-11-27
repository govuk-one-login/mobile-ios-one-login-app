import Foundation
import MobilePlatformServices
import Networking
@testable import OneLogin
import XCTest

final class AppEnvironmentTests: XCTestCase {
    func test_appEnvironmentValues() throws {
        let sut = AppEnvironment.self
        XCTAssertEqual(sut.oneLoginAuthorize, URL(string: "https://auth-stub.mobile.build.account.gov.uk/authorize"))
        XCTAssertEqual(sut.oneLoginToken, URL(string: "https://mobile.build.account.gov.uk/token"))
        XCTAssertEqual(sut.privacyPolicyURL, URL(string: "https://signin.account.gov.uk/privacy-notice?lng=en"))
        XCTAssertEqual(sut.manageAccountURL, URL(string: "https://signin.account.gov.uk/sign-in-or-create?lng=en"))
        XCTAssertEqual(sut.oneLoginClientID, "TEST_CLIENT_ID")
        XCTAssertEqual(sut.oneLoginRedirect, "https://mobile.build.account.gov.uk/redirect")
        XCTAssertEqual(sut.oneLoginBaseURLString, "mobile.build.account.gov.uk")
        XCTAssertEqual(sut.oneLoginBaseURL, URL(string: "https://mobile.build.account.gov.uk"))
        XCTAssertEqual(sut.stsAuthorize, URL(string: "https://token.build.account.gov.uk/authorize"))
        XCTAssertEqual(sut.stsToken, URL(string: "https://token.build.account.gov.uk/token"))
        XCTAssertEqual(sut.stsHelloWorld, URL(string: "https://hello-world.token.build.account.gov.uk/hello-world"))
        XCTAssertEqual(sut.stsBaseURLString, "token.build.account.gov.uk")
        XCTAssertEqual(sut.stsBaseURL, URL(string: "https://token.build.account.gov.uk"))
        XCTAssertEqual(sut.jwksURL, URL(string: "https://token.build.account.gov.uk/.well-known/jwks.json"))
        XCTAssertEqual(sut.appInfoURL, URL(string: "https://mobile.build.account.gov.uk/appInfo"))
        XCTAssertEqual(sut.stsClientID, "bYrcuRVvnylvEgYSSbBjwXzHrwJ")
        XCTAssertEqual(sut.isLocaleWelsh, false)
        XCTAssertEqual(sut.appStoreURL, URL(string: "https://apps.apple.com"))
        XCTAssertEqual(sut.appStore, URL(string: "https://apps.apple.com/gb.app.uk.gov.digital-identity"))
        XCTAssertEqual(sut.yourServicesURL, URL(string: "https://home.account.gov.uk/your-services?lng=en"))
        XCTAssertEqual(sut.yourServicesLink, "home.account.gov.uk")
        XCTAssertEqual(sut.walletCredentialIssuer, "https://example-credential-issuer.mobile.build.account.gov.uk")
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
