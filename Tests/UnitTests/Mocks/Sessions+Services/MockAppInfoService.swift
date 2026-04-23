import Foundation
@testable import MobilePlatformServices
import Networking
import XCTest

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


final class MockAppInformationServiceExpectation: AppInformationProvider {
    var currentVersion: Version {
        mockAppInformationService.currentVersion
    }

    let mockAppInformationService: MockAppInformationService
    var expectation: XCTestExpectation
    
    init(mockAppInformationService: MockAppInformationService = MockAppInformationService(), expectation: XCTestExpectation) {
        self.mockAppInformationService = mockAppInformationService
        self.expectation = expectation
    }
    
    func fetchAppInfo() async throws -> App {
        defer {
            expectation.fulfill()
        }

        return try await mockAppInformationService.fetchAppInfo()
    }
}
