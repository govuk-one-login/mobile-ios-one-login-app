import Foundation
import SecureStore

// This protocol and conforming types will be removed following an agreed end to the migration period
// based on information from Firebase Crashlytics
protocol SecureStoreMigrationManaging {
    func checkItemExists(_ itemName: String) -> Bool
    func saveItemToNewStoreRemoveFromOldStore(_ item: String, itemName: String) throws
    func readItem(_ itemName: String) throws -> String
    func deleteItem(_ itemName: String)
}

extension SecureStoreMigrationManaging {
    func saveDate(
        id: String,
        _ date: Date
    ) throws {
        try saveItemToNewStoreRemoveFromOldStore(
            date.timeIntervalSince1970.description,
            itemName: id
        )
    }
    
    func readDate(id: String) throws -> Date {
        let dateString = try readItem(id)
        guard let dateDouble = Double(dateString) else {
            throw SecureStoreError.cantDecodeData
        }
        return Date(timeIntervalSince1970: dateDouble)
    }
}

enum SecureStoreMigrationError: Error {
    case migratedFromv12Tov13
}
