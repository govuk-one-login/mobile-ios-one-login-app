import Foundation
import Networking

public struct App: Decodable {
    public let minimumVersion: Version
    public let allowAppUsage: Bool
    public let releaseFlags: [String: Bool]

    init(minimumVersion: Version,
         allowAppUsage: Bool,
         releaseFlags: [String: Bool]) {
        self.minimumVersion = minimumVersion
        self.allowAppUsage = allowAppUsage
        self.releaseFlags = releaseFlags
    }

    enum CodingKeys: String, CodingKey {
        case minimumVersion
        case allowAppUsage = "available"
        case releaseFlags
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.minimumVersion = try container.decode(Version.self, forKey: .minimumVersion)
        self.allowAppUsage = try container.decodeIfPresent(Bool.self, forKey: .allowAppUsage) ?? true
        self.releaseFlags = try container.decodeIfPresent([String: Bool].self, forKey: .releaseFlags) ?? [:]
    }
}
