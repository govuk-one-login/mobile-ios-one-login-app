import Foundation
@testable import MobilePlatformServices
import Networking

@testable import OneLogin

final class MockAppInformationService: AppInformationProvider {
    var currentVersion: Networking.Version = .init(.max, .max, .max)
    var allowAppUsage = true
    var didCallFetchAppInfo = false
    
    var errorFromFetchAppInfo: Error?
    
    var releaseFlags: [String: Bool] = [:]
    var featureFlags: [String: Bool] = [:]
    
    func fetchAppInfo() async throws -> App {
        defer {
            didCallFetchAppInfo = true
        }
        if let errorFromFetchAppInfo {
            throw errorFromFetchAppInfo
        }
        
        return App(minimumVersion: .init(1, 2, 0),
                   allowAppUsage: allowAppUsage,
                   releaseFlags: releaseFlags,
                   featureFlags: featureFlags)
    }
}
