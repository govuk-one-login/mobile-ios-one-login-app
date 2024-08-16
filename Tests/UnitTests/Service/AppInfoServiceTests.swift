import Foundation
import MockNetworking
@testable import Networking
@testable import OneLogin
import XCTest

final class AppInfoServiceTests: XCTestCase {
    private var sut: AppInformationService!
    private func createMock(minimumVersion: String = "1.0.0",
                            available: Bool = true,
                            releaseFlags: [Bool] = [true, false]) -> Data {
        
        Data(
            """
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
    
    override static func setUp() {
        let url = URL(string: "https://example.com/dev")!
        Service.initialize(baseURL: url)
    }
    
    override func setUp() {
        super.setUp()
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let client = NetworkClient(configuration: configuration)
        
        sut = .init(client: client)
    }
    
    
    override func tearDown() {
        super.tearDown()
        sut = nil
        MockURLProtocol.clear()
    }
}

extension AppInfoServiceTests {
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
        XCTAssertEqual(request.url?.host, "example.com")
        XCTAssertEqual(request.url?.path, "/dev/appInfo")
        
        XCTAssertEqual(version, Version(1, 0, 0))
    }
    
    func test_isSupportedVersion_makesNetworkCall() throws {
        MockURLProtocol.handler = {
            (self.createMock(), HTTPURLResponse(statusCode: 200))
        }
        
        Task { try await sut.fetchAppInfo() }
        
        let exp = expectation(for: .init { _, _ in
            !MockURLProtocol.requests.isEmpty
        }, evaluatedWith: nil)
        wait(for: [exp], timeout: 2)
        
        let request = try XCTUnwrap(MockURLProtocol.requests.first)
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(request.url?.scheme, "https")
        XCTAssertEqual(request.url?.host, "example.com")
        XCTAssertEqual(request.url?.path, "/dev/appInfo")
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
    
    func test_appInfoIsDecoded_releaseFlags() async throws {
        MockURLProtocol.handler = {
            (self.createMock(), HTTPURLResponse(statusCode: 200))
        }
        
        let appInfo = try await sut.fetchAppInfo()
        XCTAssertEqual(appInfo.releaseFlags, ["Feature1": true,
                                              "Feature2": false])
    }
}
