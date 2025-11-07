import AppIntegrity
import Foundation

extension UserDefaults: SessionBoundData {
    func clearSessionData() throws {
        removeObject(forKey: OLString.returningUser)
        removeObject(forKey: OLString.accessTokenExpiry)
    }
}
