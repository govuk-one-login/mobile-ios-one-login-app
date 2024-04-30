import Foundation
import Networking

protocol NetworkClientele {
    func makeAuthorizedRequest(exchangeRequest: URLRequest,
                               scope: String,
                               request: URLRequest) async throws -> Data
}

extension NetworkClient: NetworkClientele { }
