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

extension GAnalyticsV2: @retroactive WalletAnalyticsService & IDCheckAnalyticsService { }

// TODO: add IDCheckNetworkClient when branch feature/dcmaw-16211-one-login-network-client-service merges in ID Check SDK
typealias OneLoginNetworkingService = OneLoginNetworkClient & MPTServicesNetworkClient & WalletNetworkClient & IDCheckNetworkClient

typealias OneLoginAnalyticsService = AnalyticsServiceV2 & IDCheckAnalyticsService & WalletAnalyticsService

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

final class WalletAuthorizedHTTPLogger: WalletTxMALogger {
    /// `URL` address for sending HTTP requests
    let loggingURL: URL
    /// `NetworkClient` from the Networking package dependency to handle HTTP networking
    let networkingService: OneLoginNetworkingService
    /// Scope for service access token
    let scope: String
    /// callback to handle possible errors resulting from `NetworkClient`'s `makeRequest` method
    let handleError: ((Error) -> Void)?

    init(
        url: URL,
        networkingService: OneLoginNetworkingService,
        scope: String,
        handleError: ((Error) -> Void)? = nil
    ) {
        self.loggingURL = url
        self.scope = scope
        self.networkingService = networkingService
        self.handleError = handleError
    }
    
    func logEvent(_ event: any WalletTxMAEvent) async {
        await logEvent(requestBody: event)
    }

    /// Sends HTTP POST request to designated URL, handling errors received back from `NetworkClient`'s `makeAuthorizedRequest` method
    /// - Parameters:
    ///     - event: the encodable object to be logged in the request body as JSON
    @discardableResult
    public func logEvent(requestBody: any Encodable) -> Task<Void, Never>? {
        guard let jsonData = try? JSONEncoder().encode(requestBody) else {
            assertionFailure("Failed to encode object")
            return nil
        }

        return Task {
            await createAndMakeRequest(data: jsonData)
        }
    }
    
    public func logEvent(requestBody: any Encodable) async {
        guard let jsonData = try? JSONEncoder().encode(requestBody) else {
            assertionFailure("Failed to encode object")
            return
        }
        
        await createAndMakeRequest(data: jsonData)
    }
    
    private func createAndMakeRequest(data: Data) async {
        var request = URLRequest(url: loggingURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        
        do {
            _ = try await networkingService.makeAuthorizedRequest(
                scope: scope,
                request: request
            )
        } catch {
            handleError?(error)
        }
    }
}
