import Combine

protocol UserProvider {
    var user: CurrentValueSubject<(any User)?, Never> { get }
}
