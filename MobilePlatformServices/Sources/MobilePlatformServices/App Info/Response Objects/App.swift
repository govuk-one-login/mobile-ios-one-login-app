import Foundation
import Networking

public struct App: Decodable {
    public let minimumVersion: Version
    public let allowAppUsage: Bool
    public let releaseFlags: [String: Bool]
    public let featureFlags: [String: Bool]

    init(minimumVersion: Version,
         allowAppUsage: Bool,
         releaseFlags: [String: Bool],
         featureFlags: [String: Bool]) {
        self.minimumVersion = minimumVersion
        self.allowAppUsage = allowAppUsage
        self.releaseFlags = releaseFlags
        self.featureFlags = featureFlags
    }

    enum CodingKeys: String, CodingKey {
        case minimumVersion
        case allowAppUsage = "available"
        case releaseFlags
        case featureFlags
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.minimumVersion = try container.decode(Version.self, forKey: .minimumVersion)
        self.allowAppUsage = try container.decodeIfPresent(Bool.self, forKey: .allowAppUsage) ?? true
        self.releaseFlags = try container.decodeIfPresent([String: Bool].self, forKey: .releaseFlags) ?? [:]
        self.featureFlags = try container.decodeIfPresent([String: Bool].self, forKey: .featureFlags) ?? [:]
    }
}
