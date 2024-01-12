import Foundation

protocol Flaggable {
    var name: String { get }
    var isEnabled: Bool { get }
}

struct Flag: Flaggable, Codable {
    var name: String
    var isEnabled: Bool
}
