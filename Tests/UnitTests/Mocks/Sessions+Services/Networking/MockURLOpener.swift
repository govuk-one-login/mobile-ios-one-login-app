import Foundation
import OneLogin

final class MockURLOpener: URLOpener {
    var didOpenURL = false
    
    func open(url: URL) {
        didOpenURL = true
    }
}
