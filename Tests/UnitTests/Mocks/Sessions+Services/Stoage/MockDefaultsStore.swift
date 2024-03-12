import Foundation
@testable import OneLogin

class MockDefaultsStore: DefaultsStorable {
    var savedData = [String: Any]()
    var returningAuthenticatedUser: Bool?
    var returnExpDate: Date?
    
    func set(_ value: Any?, forKey defaultName: String) {
        savedData[defaultName] = value
    }
    
    func value(forKey key: String) -> Any? {
        if key == .returningUser || key == .accessTokenExpiry {
            if let returningAuthenticatedUser {
                return returningAuthenticatedUser
            }
        } else if key == .accessTokenExpiry {
            if let returnExpDate {
                return returnExpDate
            }
        }
        return nil
    }
    
    func removeObject(forKey defaultName: String) { }
}
