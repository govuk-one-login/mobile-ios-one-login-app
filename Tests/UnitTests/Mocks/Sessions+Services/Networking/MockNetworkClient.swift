import Foundation
@testable import OneLogin

final class MockNetworkClient: RequestAuthorizing {
    var authorizedData: Data?

    var requestFinished: Bool = false

    func makeAuthorizedRequest(exchangeRequest: URLRequest,
                               scope: String,
                               request: URLRequest) async throws -> Data {
        defer {
            requestFinished = true
        }
        if let authorizedData {
            return authorizedData
        } else {
            throw MockNetworkClientError.genericError
        }
    }
}

enum MockNetworkClientError: Error {
    case genericError
}
