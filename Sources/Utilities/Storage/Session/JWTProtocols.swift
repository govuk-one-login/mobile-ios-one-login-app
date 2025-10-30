protocol User {
    var persistentID: String { get }
    var email: String { get }
}

protocol RefreshToken {
    var expiryDate: String { get }
}
