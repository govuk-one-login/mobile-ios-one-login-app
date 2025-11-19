import AppIntegrity
import Authentication
import Foundation
import MobilePlatformServices
import Networking

protocol OneLoginNetworkClient {
    func makeRequest(_ request: URLRequest) async throws -> Data

    func makeAuthorizedRequest(
        scope: String,
        request: URLRequest
    ) async throws -> Data
}

final class NetworkService: OneLoginNetworkClient, TokenExchangeManaging, MPTServicesNetworkClient {
    let networkClient: NetworkClient
    
    init(networkClient: NetworkClient = NetworkClient()) {
        self.networkClient = networkClient
    }
    
    func getUpdatedTokens(
        refreshToken: String,
        appIntegrityProvider: AppIntegrityProvider
    ) async throws -> TokenResponse {
        do {
            let exchangeResponse = try await makeRequest(
                .refreshTokenExchange(
                    token: refreshToken,
                    appIntegrityProvider: appIntegrityProvider
                )
            )
            
            return try JSONDecoder()
                .decode(TokenResponse.self, from: exchangeResponse)
        } catch let error as FirebaseAppCheckError where error.errorType == .network,
                let error as FirebaseAppCheckError where error.errorType == .unknown,
                let error as FirebaseAppCheckError where error.errorType == .generic {
            return try await getUpdatedTokens(
                refreshToken: refreshToken,
                appIntegrityProvider: appIntegrityProvider
            )
        } catch {
            NotificationCenter.default.post(name: .accountIntervention)
            throw error
        }
    }
    
    func makeRequest(_ request: URLRequest) async throws -> Data {
        do {
            return try await networkClient.makeRequest(request)
        } catch let error as URLError where error.code == .notConnectedToInternet {
            throw error
        }
    }
    
    func makeAuthorizedRequest(
        scope: String,
        request: URLRequest
    ) async throws -> Data {
        do {
            return try await networkClient.makeAuthorizedRequest(
                scope: scope,
                request: request
            )
        } catch let error as URLError where error.code == .notConnectedToInternet {
            throw error
        }
    }
}
