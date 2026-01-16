import AppIntegrity
import CRIOrchestrator
import Foundation
import GAnalytics
import HTTPLogging
import Logging
import MobilePlatformServices
import Networking
import Wallet

extension AuthorizedHTTPLogger: @retroactive WalletTxMALogger {
    public func logEvent(_ event: any WalletTxMAEvent) async {
        await logEvent(requestBody: event)
    }
}

extension NetworkingService: OneLoginNetworkingService { }

extension GAnalyticsV2: @retroactive WalletAnalyticsService, @retroactive IDCheckAnalyticsService { }

typealias OneLoginNetworkingService = MPTServicesNetworkClient & WalletNetworkClient & IDCheckNetworkClient & AppIntegrityNetworkClient & HTTPLoggingNetworkClient
typealias OneLoginAnalyticsService = AnalyticsServiceV2 & WalletAnalyticsService & IDCheckAnalyticsService

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

extension CRIOrchestrator: CRIOrchestration { }

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
