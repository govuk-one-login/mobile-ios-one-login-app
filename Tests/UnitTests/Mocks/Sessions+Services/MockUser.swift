@testable import OneLogin

struct MockUser: User {
    var persistentID: String = "ABC123"
    var email: String = "test@example.com"
}
