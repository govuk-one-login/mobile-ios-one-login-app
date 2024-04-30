import Foundation
@testable import OneLogin

final class MockNetworkClient: NetworkClientele {
    var authorizedData: Data?
    var authorizedError: Error?

    var requestFinished: Bool = false

    func makeAuthorizedRequest(exchangeRequest: URLRequest, scope: String, request: URLRequest) async throws -> Data {
        defer {
            requestFinished = true
        }
        if let authorizedData {
            return authorizedData
        } else {
            requestFinished = true
            throw MockNetworkClientError.genericError
        }
    }
}

enum MockNetworkClientError: Error {
    case genericError
}
