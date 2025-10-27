import AppIntegrity
import Foundation

extension UserDefaults: SessionBoundData {
    func delete() throws {
        removeObject(forKey: OLString.returningUser)
        removeObject(forKey: OLString.accessTokenExpiry)
        removeObject(forKey: OLString.encryptedStore)
        removeObject(forKey: OLString.storedTokens)
        removeObject(forKey: OLString.biometricsPrompt)
    }
}
