import Foundation
import GDSCommon

final class MockURLOpener: URLOpener {
    var didOpenURL = false

    func open(url: URL) {
        didOpenURL = true
    }
}
