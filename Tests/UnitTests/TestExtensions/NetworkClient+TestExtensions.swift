import CRIOrchestrator
import Foundation
import Networking
import WalletInterface

extension NetworkClient: @retroactive IDCheckNetworkClient, @retroactive WalletNetworkClient {
    public func request(_ request: URLRequest) -> any WalletInterface.WalletRequestBuilder {
        return RequestBuilder(client: self, request: request)
    }
}
