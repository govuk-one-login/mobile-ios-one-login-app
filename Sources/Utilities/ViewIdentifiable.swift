import UIKit

protocol ViewIdentifiable {
    static var identifier: String { get }
}

extension ViewIdentifiable where Self: UIView {
    static var identifier: String {
        NSStringFromClass(Self.self)
    }
}
