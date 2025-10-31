import AppIntegrity
import Foundation

extension UserDefaults: SessionBoundData {
    func delete() throws {
        OLString.UDKeyStrings.allCases
            .forEach { removeObject(forKey: $0.rawValue) }
    }
}
