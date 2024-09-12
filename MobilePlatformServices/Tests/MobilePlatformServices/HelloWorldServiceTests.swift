import Foundation
@testable import MobilePlatformServices
import MockNetworking
@testable import Networking
import XCTest

final class HelloWorldServiceTests: XCTestCase {
    private var sut: HelloWorldService!
    private var configuration: URLSessionConfiguration!
    private var client: NetworkClient!

    private var didRequestScope: String?

    override func setUp() {
        super.setUp()

        configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        client = NetworkClient(configuration: configuration)
        client.authorizationProvider = self

        let url = URL(string: "https://hello-world.mobile.build.account.gov.uk/hello-world")!
        sut = HelloWorldService(client: client, baseURL: url)
    }

    override func tearDown() {
        configuration = nil
        MockURLProtocol.clear()
        client = nil
        sut = nil

        super.tearDown()
    }
}

extension HelloWorldServiceTests {
    public func testRequestHelloWorld_makesNetworkCall() async throws {
        MockURLProtocol.handler = {
            let data = Data("""
            Hello World - Tests
            """.utf8)
            return (data, HTTPURLResponse(statusCode: 200))
        }

        let response = try await sut.requestHelloWorld()

        XCTAssertEqual(MockURLProtocol.requests.count, 1)

        XCTAssertEqual(didRequestScope, "sts-test.hello-world.read")

        let request = try XCTUnwrap(MockURLProtocol.requests.first)
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(request.url?.scheme, "https")
        XCTAssertEqual(request.url?.host, "hello-world.mobile.build.account.gov.uk")
        XCTAssertEqual(request.url?.path, "/hello-world")

        XCTAssertEqual(response, "Success: Hello World - Tests")
    }

    public func testRequestHelloWorldWrongScope_makesNetworkCall() async throws {
        MockURLProtocol.handler = {
            let data = Data("""

            """.utf8)
            return (data, HTTPURLResponse(statusCode: 200))
        }

        _ = try await sut.requestHelloWorldWrongScope()

        XCTAssertEqual(MockURLProtocol.requests.count, 1)

        XCTAssertEqual(didRequestScope, "sts-test.hello-world")

        let request = try XCTUnwrap(MockURLProtocol.requests.first)
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(request.url?.scheme, "https")
        XCTAssertEqual(request.url?.host, "hello-world.mobile.build.account.gov.uk")
        XCTAssertEqual(request.url?.path, "/hello-world")
    }

    public func testRequestHelloWorldWrongEndpoint_makesNetworkCall() async throws {
        MockURLProtocol.handler = {
            let data = Data("""

            """.utf8)
            return (data, HTTPURLResponse(statusCode: 200))
        }

        _ = try await sut.requestHelloWorldWrongEndpoint()

        XCTAssertEqual(MockURLProtocol.requests.count, 1)

        XCTAssertEqual(didRequestScope, "sts-test.hello-world.read")

        let request = try XCTUnwrap(MockURLProtocol.requests.first)
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(request.url?.scheme, "https")
        XCTAssertEqual(request.url?.host, "hello-world.mobile.build.account.gov.uk")
        XCTAssertEqual(request.url?.path, "/hello-world/error")
    }
}

extension HelloWorldServiceTests: AuthorizationProvider {
    func fetchToken(withScope scope: String) async throws -> String {
        didRequestScope = scope
        return "mock_token"
    }
}
