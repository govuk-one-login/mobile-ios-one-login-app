import Foundation
import Networking

public protocol MPTServicesNetworkClient {
    func request(_ request: URLRequest) -> RequestBuilder
}

public final class HelloWorldService: HelloWorldProvider {
    private let client: MPTServicesNetworkClient
    private let baseURL: URL

    public init(client: MPTServicesNetworkClient, baseURL: URL) {
        self.client = client
        self.baseURL = baseURL
    }

    public func requestHelloWorld() async throws -> String {
        let data = try await client.request(URLRequest(url: baseURL))
            .withAuthentication(scope: "sts-test.hello-world.read")
            .execute()
        return "Success: \(String(data: data, encoding: .utf8) ?? "Couldn't decode data")"
    }

    public func requestHelloWorldWrongScope() async throws {
        _ = try await client.request(URLRequest(url: baseURL))
            .withAuthentication(scope: "sts-test.hello-world")
            .execute()
    }

    public func requestHelloWorldWrongEndpoint() async throws {
        _ = try await client
            .request(URLRequest(url: baseURL.appendingPathComponent("error")))
            .withAuthentication(scope: "sts-test.hello-world.read")
            .execute()
    }
}
