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
    private let networkService: MPTServicesNetworkClient
    private let baseURL: URL

    public init(
        networkService: MPTServicesNetworkClient,
        baseURL: URL
    ) {
        self.networkService = networkService
        self.baseURL = baseURL
    }

    public func requestHelloWorld() async throws -> String {
        let data = try await networkService
            .makeAuthorizedRequest(scope: "sts-test.hello-world.read",
                                   request: URLRequest(url: baseURL))
        return "Success: \(String(data: data, encoding: .utf8) ?? "Couldn't decode data")"
    }

    public func requestHelloWorldWrongScope() async throws {
        _ = try await networkService
            .makeAuthorizedRequest(scope: "sts-test.hello-world",
                                   request: URLRequest(url: baseURL))
    }

    public func requestHelloWorldWrongEndpoint() async throws {
        _ = try await networkService
            .makeAuthorizedRequest(scope: "sts-test.hello-world.read",
                                   request: URLRequest(url: baseURL.appendingPathComponent("error")))
    }
}
