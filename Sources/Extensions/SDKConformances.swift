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
        environment: WalletEnvironment(buildConfiguration: AppEnvironment.buildConfiguration.lowercased()),
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
    let readIDURLString: String = AppEnvironment.readIDURLString
    let iProovURLString: String = AppEnvironment.iProovURLString
}

extension WalletEnvironment {
    public init?(buildConfiguration: String) {
        switch buildConfiguration {
        case "release":
            self = .production
        default:
            guard let config = Self.init(rawValue: buildConfiguration) else {
                return nil
            }
            self = config
        }
    }
}
