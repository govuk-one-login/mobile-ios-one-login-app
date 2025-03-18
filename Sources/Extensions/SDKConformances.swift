import CRIOrchestrator
import Foundation
import GAnalytics
import HTTPLogging
import Logging
import Networking
import Wallet

extension AuthorizedHTTPLogger: @retroactive WalletTxMALogger { }

extension NetworkClient: @retroactive WalletNetworkClient { }

extension GAnalytics: @retroactive WalletAnalyticsService & IDCheckAnalyticsService { }

typealias OneLoginAnalyticsService = AnalyticsService & IDCheckAnalyticsService & WalletAnalyticsService

extension WalletConfig {
    static let oneLoginWalletConfig = WalletConfig(
        environment: WalletEnvironment(rawValue: AppEnvironment.buildConfiguration.lowercased()),
        credentialIssuer: AppEnvironment.walletCredentialIssuer.absoluteString,
        clientID: AppEnvironment.stsClientID
    )
}

struct OneLoginCRIURLs: CRIURLs {
    let criBaseURL: URL = AppEnvironment.idCheckAsyncBaseURL
    let govSupportURL: URL = AppEnvironment.govSupportURL
    let handoffURL: URL = AppEnvironment.idCheckHandoffURL
    let baseURL: URL = AppEnvironment.idCheckBaseURL
    let domainURL: URL = AppEnvironment.idCheckDomainURL
    let govUKURL: URL = AppEnvironment.govURL
    let readIDURLString: String = AppEnvironment.readIDURL.absoluteString
    let iProovURLString: String = AppEnvironment.iProovURL.absoluteString
}
