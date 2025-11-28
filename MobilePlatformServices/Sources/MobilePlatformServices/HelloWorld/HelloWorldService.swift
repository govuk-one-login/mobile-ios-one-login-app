import Foundation
import Networking

public protocol MPTServicesNetworkClient {
    func makeRequest(_ request: URLRequest) async throws -> Data

    func makeAuthorizedRequest(
        scope: String,
        request: URLRequest
    ) async throws -> Data
}

public final class HelloWorldService: HelloWorldProvider {
    private let client: MPTServicesNetworkClient
    private let baseURL: URL

    public init(client: NetworkClient, baseURL: URL) {
        self.client = client
        self.baseURL = baseURL
    }

    public func requestHelloWorld() async throws -> String {
        let data = try await client
            .makeAuthorizedRequest(scope: "sts-test.hello-world.read",
                                   request: URLRequest(url: baseURL))
        return "Success: \(String(data: data, encoding: .utf8) ?? "Couldn't decode data")"
    }

    public func requestHelloWorldWrongScope() async throws {
        _ = try await client
            .makeAuthorizedRequest(scope: "sts-test.hello-world",
                                   request: URLRequest(url: baseURL))
    }

    public func requestHelloWorldWrongEndpoint() async throws {
        _ = try await client
            .makeAuthorizedRequest(scope: "sts-test.hello-world.read",
                                   request: URLRequest(url: baseURL.appendingPathComponent("error")))
    }
}
