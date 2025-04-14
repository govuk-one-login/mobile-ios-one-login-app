import Foundation
@testable import MobilePlatformServices
import Networking

@testable import OneLogin

final class MockAppInformationService: AppInformationProvider {
    var currentVersion: Networking.Version = .init(.max, .max, .max)
    var allowAppUsage = true
    var didCallFetchAppInfo = false
    
    var errorToThrow: Error?
    var apps: Data = Data(
    """
        {
          "apps": {
            "iOS": {
              "minimumVersion": "1.0.0",
              "releaseFlags": {
                "walletVisibleViaDeepLink": true,
                "walletVisibleIfExists": true,
                "walletVisibleToAll": false
              },
              "available": true,
              "featureFlags": {
                "appCheckEnabled": true
              }
            }
          }
        }
    """.utf8)

    var releaseFlags: [String: Bool] = [:]
    var featureFlags: [String: Bool] = [:]

    func fetchAppInfo() async throws -> App {
        defer {
            didCallFetchAppInfo = true
        }
        
        if let errorToThrow {
            throw errorToThrow
        }
        guard let appInfo = try? JSONDecoder().decode(AppInfoResponse.self, from: apps) else {
            throw AppInfoError.invalidResponse
        }

        return appInfo.appList.iOS
    }
}
