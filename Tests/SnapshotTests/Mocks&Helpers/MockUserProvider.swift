import Combine
@testable import OneLogin

final class MockUserProvider: UserProvider {
    var user = CurrentValueSubject<(any OneLogin.User)?, Never>(nil)
}
