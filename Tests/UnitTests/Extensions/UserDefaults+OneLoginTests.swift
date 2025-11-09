import Foundation
@testable import OneLogin
import Testing

@Suite(.serialized)
struct UserDefaultsTests: ~Copyable {
    let userDefaults: UserDefaults
    
    init() throws {
        userDefaults = try #require(UserDefaults(suiteName: "unitTestSuite"))
        userDefaults.set(
            OLString.accessTokenExpiry,
            forKey: OLString.accessTokenExpiry
        )
        userDefaults.set(
            OLString.returningUser,
            forKey: OLString.returningUser
        )
    }
    
    deinit {
        userDefaults.removeSuite(named: "unitTestSuite")
    }
    
    @Test("Clear session data deletes the access token expiry date and returning user flag")
    func callDelete() throws {
        #expect(userDefaults.object(forKey: OLString.accessTokenExpiry) as? String == OLString.accessTokenExpiry)
        #expect(userDefaults.object(forKey: OLString.returningUser) as? String == OLString.returningUser)
        #expect(userDefaults.object(forKey: OLString.returningUser) as? String == OLString.migratedEncryptedStoreToV13)
        #expect(userDefaults.object(forKey: OLString.returningUser) as? String == OLString.migratedAccessControlEncryptedStoreToV13)
        try userDefaults.clearSessionData()
        #expect(userDefaults.object(forKey: OLString.accessTokenExpiry) == nil)
        #expect(userDefaults.object(forKey: OLString.returningUser) == nil)
        #expect(userDefaults.object(forKey: OLString.migratedEncryptedStoreToV13) == nil)
        #expect(userDefaults.object(forKey: OLString.migratedAccessControlEncryptedStoreToV13) == nil)
    }
}
