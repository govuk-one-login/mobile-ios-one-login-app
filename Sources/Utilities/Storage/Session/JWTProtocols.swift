import Foundation

protocol User {
    var persistentID: String { get }
    var walletStoreID: String { get }
    var email: String { get }
}

protocol RefreshToken {
    var expiryDate: Date { get }
}
