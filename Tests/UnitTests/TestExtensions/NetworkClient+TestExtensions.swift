import CRIOrchestrator
import Networking
import Wallet

extension NetworkClient: @retroactive IDCheckNetworkClient, @retroactive WalletNetworkClient {}
