import AppIntegrity
import CRIOrchestrator
import Foundation
import GAnalytics
import HTTPLogging
import Logging
import MobilePlatformServices
import Networking
import Wallet
import WalletInterface

extension AuthorizedHTTPLogger: @retroactive WalletTxMALogger {
    public func logEvent(_ event: any WalletTxMAEvent) async {
        await logEvent(requestBody: event)
    }
}

extension NetworkingService: OneLoginNetworkingService { }

extension WalletNetworkClientWrapper: WalletNetworkClient {
    public func request(_ request: URLRequest) -> any WalletRequestBuilder {
        RequestBuilder(client: self, request: request)
    }
}

typealias OneLoginNetworkingService = MPTServicesNetworkClient & IDCheckNetworkClient & AppIntegrityNetworkClient & HTTPLoggingNetworkClient

extension RequestBuilder: @retroactive WalletRequestBuilder {}

extension GAnalytics: @retroactive WalletAnalyticsService, @retroactive IDCheckAnalyticsService { }

typealias OneLoginAnalyticsService = AnalyticsService & WalletAnalyticsService & IDCheckAnalyticsService

extension WalletEnvironment {
    public init?(buildConfiguration: String) {
        switch buildConfiguration {
        case "release":
            self = .production
        #if DEBUG
        case "debug":
            self  = .build
        #endif
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
