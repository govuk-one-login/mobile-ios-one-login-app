import AppIntegrity
import Foundation

extension UserDefaults: SessionBoundData {
    func clearSessionData() throws {
        OLString.UnprotectedStoreKeyString.allCases.forEach {
            removeObject(forKey: $0.rawValue)
        }
    }
}
