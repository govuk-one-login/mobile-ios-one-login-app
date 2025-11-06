import Foundation
import SecureStore

protocol SecureStoreManaging {
    func checkItemExists(_ itemName: String) -> Bool
    func saveItem(_ item: String, itemName: String) throws
    func readItem(_ itemName: String) throws -> String
    func deleteItem(_ itemName: String)
}

extension SecureStoreManaging {
    func saveDate(
        id: String,
        _ date: Date
    ) throws {
        try saveItem(
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
