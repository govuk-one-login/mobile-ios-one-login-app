import Foundation
import Networking

@testable import OneLogin

final class MockAppInformationService: AppInformationServicing {
    var currentVersion: Networking.Version = .init(.max, .max, .max)

    var didCallFetchAppInfo = false
    var shouldReturnError = false
    
    var errorToThrow: Error?
        
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
        
        return App(minimumVersion: .init(1, 2, 0), allowAppUsage: true, releaseFlags: [:])
    }
}
