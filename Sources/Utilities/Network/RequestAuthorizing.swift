import Foundation
import Networking

protocol RequestAuthorizing {
    func makeAuthorizedRequest(exchangeRequest: URLRequest,
                               scope: String,
                               request: URLRequest) async throws -> Data
}

extension NetworkClient: RequestAuthorizing { }
