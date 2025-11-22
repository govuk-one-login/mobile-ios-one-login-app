import Foundation
@testable import MobilePlatformServices
import MockNetworking
@testable import Networking
import XCTest

final class AppInformationServiceTests: XCTestCase {
    private var sut: AppInformationService!
    private var configuration: URLSessionConfiguration!
    private var client: NetworkClient!
    private var mockCache: MockAppInfoCache!
    private func createMock(
        available: Bool = true,
        minimumVersion: String = "1.0.0",
        releaseFlags: [Bool] = [true, false]
    ) -> Data {
        Data("""
                {
                    "apps": {
                        "android": {
                            "minimumVersion": "\(minimumVersion)"
                        },
                        "iOS": {
                            "available": \(available),
                            "minimumVersion": "\(minimumVersion)",
                            "releaseFlags": {
                                \(flagFactory(releaseFlags))
                            }
                        }
                    }
                }
        """.utf8)
    }
    
    private func flagFactory(_ flags: [Bool]) -> String {
        flags
            .enumerated()
            .map {
                "\"Feature\($0+1)\": \($1)"
            }
            .joined(separator: ",\n")
    }
    
    override func setUp() {
        super.setUp()
        
        configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        client = NetworkClient(configuration: configuration)
        mockCache = MockAppInfoCache()

        let url = URL(string: "https://mobile.build.account.gov.uk/appInfo")!
        sut = AppInformationService(
            networkingService: client,
            baseURL: url,
            cache: mockCache
        )
    }
    
    override func tearDown() {
        configuration = nil
        MockURLProtocol.clear()
        client = nil
        sut = nil
        mockCache = nil
        
        super.tearDown()
    }
}

extension AppInformationServiceTests {
    func test_currentAppVersion() {
        XCTAssertEqual(sut.currentVersion, Version(1, 0, 0))
    }
    
    func test_appInfoIsDecoded_usageIsTrue() async throws {
        MockURLProtocol.handler = {
            (self.createMock(), HTTPURLResponse(statusCode: 200))
        }
        
        let appInfo = try await sut.fetchAppInfo()
        XCTAssertTrue(appInfo.allowAppUsage)
    }
    
    func test_appInfoIsDecoded_usageIsFalse() async throws {
        MockURLProtocol.handler = {
            (self.createMock(available: false), HTTPURLResponse(statusCode: 200))
        }
        
        let appInfo = try await sut.fetchAppInfo()
        XCTAssertFalse(appInfo.allowAppUsage)
    }
    
    func test_fetchAppVersion_makesNetworkCall() async throws {
        MockURLProtocol.handler = {
            (self.createMock(), HTTPURLResponse(statusCode: 200))
        }
        
        let version = try await sut.fetchAppInfo().minimumVersion
        
        XCTAssertEqual(MockURLProtocol.requests.count, 1)
        XCTAssertNotNil(version)
        
        let request = try XCTUnwrap(MockURLProtocol.requests.first)
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(request.url?.scheme, "https")
        XCTAssertEqual(request.url?.host, "mobile.build.account.gov.uk")
        XCTAssertEqual(request.url?.path, "/appInfo")
        
        XCTAssertEqual(version, Version(1, 0, 0))
    }
    
    func test_appInfoIsDecoded_releaseFlags() async throws {
        MockURLProtocol.handler = {
            (self.createMock(), HTTPURLResponse(statusCode: 200))
        }
        
        let appInfo = try await sut.fetchAppInfo()
        XCTAssertEqual(appInfo.releaseFlags, ["Feature1": true,
                                              "Feature2": false])
    }
    
    func test_fetchAppVersion_usesCachedInfo() async throws {
        mockCache.set(createMock(), forKey: "appInfoResponse")
        MockURLProtocol.handler = {
            (Data(), HTTPURLResponse(statusCode: 400))
        }
        let appInfo = try await sut.fetchAppInfo()
        
        XCTAssertEqual(appInfo.minimumVersion, Version(1, 0, 0))
    }
    
    func test_fetchAppVersion_updatesCache() async throws {
        // GIVEN there's already cached app info data
        mockCache.set(createMock(), forKey: "appInfoResponse")
        let data = try XCTUnwrap(mockCache.data(forKey: "appInfoResponse"))
        let appInfo = try? JSONDecoder().decode(AppInfoResponse.self, from: data)
        
        XCTAssertTrue(appInfo?.appList.iOS.minimumVersion == Version(1, 0, 0))
        
        // WHEN a network call is made and new data returned
        let newMock = createMock(available: true, minimumVersion: "2.0.0")
        MockURLProtocol.handler = {
            (newMock, HTTPURLResponse(statusCode: 200))
        }
        
        _ = try await sut.fetchAppInfo()
        let newCachedData = try XCTUnwrap(mockCache.data(forKey: "appInfoResponse"))
        let newAppInfo = try? JSONDecoder().decode(AppInfoResponse.self, from: newCachedData)
        
        // THEN the cached data will be updated
        XCTAssertTrue(newAppInfo?.appList.iOS.minimumVersion == Version(2, 0, 0))
    }
    
    func test_fetchAppInfoError() async throws {
        MockURLProtocol.handler = {
            (Data(), HTTPURLResponse(statusCode: 400))
        }
        
        do {
            _ = try await sut.fetchAppInfo()
        } catch let error as AppInfoError {
            XCTAssertTrue(error == .invalidResponse)
        }
    }
}
