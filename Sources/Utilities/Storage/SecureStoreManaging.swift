import Foundation
import SecureStore

protocol SecureStoreMigrationManaging {
    func checkItemExists(_ itemName: String) -> Bool
    func saveItemTov13RemoveFromv12(_ item: String, itemName: String) throws
    func readItem(_ itemName: String) throws -> String
    func deleteItem(_ itemName: String)
}

extension SecureStoreMigrationManaging {
    func saveDate(
        id: String,
        _ date: Date
    ) throws {
        try saveItemTov13RemoveFromv12(
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
