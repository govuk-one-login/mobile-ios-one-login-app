import Foundation
import Networking

public final class HelloWorldService: HelloWorldProvider {
    private let client: NetworkClient
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
