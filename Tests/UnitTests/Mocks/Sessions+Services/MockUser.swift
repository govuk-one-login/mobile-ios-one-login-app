@testable import OneLogin

struct MockUser: User {
    var persistentID: String = "ABC123"
    var walletStoreID: String = "XYZ789"
    var email: String = "test@example.com"
}
