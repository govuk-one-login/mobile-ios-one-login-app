import Foundation
import Networking

public protocol MPTServicesNetworkClient {
    func request(_ request: URLRequest) -> RequestBuilder
    
    // TODO: DCMAW-20368 Remove these
    func makeRequest(_ request: NetworkRequest) async throws -> Data

    @available(*, deprecated, message: "use .request.execute() instead")
    func makeRequest(_ request: URLRequest) async throws -> Data

    @available(*, deprecated, message: "use .request.withAuthentication().execute() instead")
    func makeAuthorizedRequest(
        scope: String,
        request: URLRequest
    ) async throws -> Data
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
