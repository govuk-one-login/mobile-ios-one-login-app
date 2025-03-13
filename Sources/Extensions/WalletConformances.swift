import CRIOrchestrator
import GAnalytics
import HTTPLogging
import Logging
import Networking
import Wallet

extension AuthorizedHTTPLogger: @retroactive WalletTxMALogger { }

extension NetworkClient: @retroactive WalletNetworkClient { }

extension GAnalytics: @retroactive WalletAnalyticsService & IDCheckAnalyticsService { }

typealias OneLoginAnalyticsService = AnalyticsService & IDCheckAnalyticsService & WalletAnalyticsService
