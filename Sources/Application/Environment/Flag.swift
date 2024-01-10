import Foundation

protocol Flaggable {
    var isEnabled: Bool { get }
    var name: String { get }
}

struct Flag: Flaggable, Codable {
    var isEnabled: Bool
    var name: String
}
