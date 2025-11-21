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
    private let networkingService: MPTServicesNetworkClient
    private let baseURL: URL

    public init(
        networkingService: MPTServicesNetworkClient,
        baseURL: URL
    ) {
        self.networkingService = networkingService
        self.baseURL = baseURL
    }

    public func requestHelloWorld() async throws -> String {
        let data = try await networkingService
            .makeAuthorizedRequest(scope: "sts-test.hello-world.read",
                                   request: URLRequest(url: baseURL))
        return "Success: \(String(data: data, encoding: .utf8) ?? "Couldn't decode data")"
    }

    public func requestHelloWorldWrongScope() async throws {
        _ = try await networkingService
            .makeAuthorizedRequest(scope: "sts-test.hello-world",
                                   request: URLRequest(url: baseURL))
    }

    public func requestHelloWorldWrongEndpoint() async throws {
        _ = try await networkingService
            .makeAuthorizedRequest(scope: "sts-test.hello-world.read",
                                   request: URLRequest(url: baseURL.appendingPathComponent("error")))
    }
}
