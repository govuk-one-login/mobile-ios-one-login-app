import Foundation
@testable import MobilePlatformServices
import Networking

@testable import OneLogin

final class MockAppInformationService: AppInformationProvider {
    var currentVersion: Networking.Version = .init(.max, .max, .max)

    var didCallFetchAppInfo = false
    var shouldReturnError = false
    
    var errorToThrow: Error?

    var releaseFlags: [String: Bool] = [:]

    func fetchAppInfo() async throws -> App {
        defer {
            didCallFetchAppInfo = true
        }
        
        if shouldReturnError {
            guard let errorToThrow else {
                throw URLError(.notConnectedToInternet)
            }
            throw errorToThrow
        }
        
        return App(minimumVersion: .init(1, 2, 0),
                   allowAppUsage: true,
                   releaseFlags: releaseFlags)
    }
}
