import Foundation
@testable import MobilePlatformServices
import MockNetworking
@testable import Networking
import XCTest

final class AppInformationServiceTests: XCTestCase {
    private var sut: AppInformationService!
    private var configuration: URLSessionConfiguration!
    private var client: NetworkClient!
    private func createMock(available: Bool = true,
                            minimumVersion: String = "1.0.0",
                            releaseFlags: [Bool] = [true, false]) -> Data {
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

        let url = URL(string: "https://mobile.build.account.gov.uk/appInfo")!
        sut = .init(client: client, baseURL: url)
    }
    
    override func tearDown() {
        configuration = nil
        MockURLProtocol.clear()
        client = nil
        sut = nil
        
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
        MockURLProtocol.handler = {
            (Data(), HTTPURLResponse(statusCode: 400))
        }
        
        let version = try await sut.fetchAppInfo().minimumVersion
        XCTAssertNotNil(sut.cache)
        XCTAssertEqual(version, Version(1, 0, 0))
    }
    
    func test_fetchAppInfoError() async throws {
        sut.cache.removeObject(forKey: "appInfoResponse")
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
