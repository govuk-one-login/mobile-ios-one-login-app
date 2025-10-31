import Foundation
@testable import OneLogin
import Testing

@Suite(.serialized)
struct UserDefaultsTests: ~Copyable {
    let userDefaults: UserDefaults
    
    init() throws {
        userDefaults = try #require(UserDefaults(suiteName: "unitTestSuite"))
        userDefaults.set(
            OLString.refreshTokenExpiry,
            forKey: OLString.refreshTokenExpiry
        )
        userDefaults.set(
            OLString.accessTokenExpiry,
            forKey: OLString.accessTokenExpiry
        )
        userDefaults.set(
            OLString.storedTokens,
            forKey: OLString.storedTokens
        )
        userDefaults.set(
            OLString.persistentSessionID,
            forKey: OLString.persistentSessionID
        )
        userDefaults.set(
            OLString.returningUser,
            forKey: OLString.returningUser
        )
        userDefaults.set(
            OLString.biometricsPrompt,
            forKey: OLString.biometricsPrompt
        )
    }
    
    deinit {
        userDefaults.removeSuite(named: "unitTestSuite")
    }
    
    @Test()
    func callDelete() throws {
        #expect(userDefaults.object(forKey: OLString.refreshTokenExpiry) as? String == OLString.refreshTokenExpiry)
        #expect(userDefaults.object(forKey: OLString.accessTokenExpiry) as? String == OLString.accessTokenExpiry)
        #expect(userDefaults.object(forKey: OLString.storedTokens) as? String == OLString.storedTokens)
        #expect(userDefaults.object(forKey: OLString.persistentSessionID) as? String == OLString.persistentSessionID)
        #expect(userDefaults.object(forKey: OLString.returningUser) as? String == OLString.returningUser)
        #expect(userDefaults.object(forKey: OLString.biometricsPrompt) as? String == OLString.biometricsPrompt)
        try userDefaults.delete()
        #expect(userDefaults.object(forKey: OLString.refreshTokenExpiry) == nil)
        #expect(userDefaults.object(forKey: OLString.accessTokenExpiry) == nil)
        #expect(userDefaults.object(forKey: OLString.storedTokens) == nil)
        #expect(userDefaults.object(forKey: OLString.persistentSessionID) == nil)
        #expect(userDefaults.object(forKey: OLString.returningUser) == nil)
        #expect(userDefaults.object(forKey: OLString.biometricsPrompt) == nil)
    }
}
