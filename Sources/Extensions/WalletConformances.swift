import HTTPLogging
import CRIOrchestrator
import GAnalytics
import Wallet
import Networking
import Logging

extension AuthorizedHTTPLogger: @retroactive WalletTxMALogger { }

extension NetworkClient: @retroactive WalletNetworkClient { }

extension GAnalytics: @retroactive WalletAnalyticsService & IDCheckAnalyticsService { }

typealias OneLoginAnalyticsService = AnalyticsService & IDCheckAnalyticsService & WalletAnalyticsService
