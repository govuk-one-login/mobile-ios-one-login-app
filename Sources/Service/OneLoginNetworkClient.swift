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

enum RefreshTokenExchangeError: Error {
    case accountIntervention
    case appIntegrityRetryError
    case noInternet
}

final class NetworkingService: OneLoginNetworkingService, TokenExchangeManaging {
    let networkClient: NetworkClient
    
    private(set) var errorRetries = 0
    
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
        } catch let error as FirebaseAppCheckError where error.errorType == .generic
                    || error.errorType == .unknown {
            guard errorRetries < 3 else {
                throw RefreshTokenExchangeError.appIntegrityRetryError
            }
            errorRetries += 1
            return try await getUpdatedTokens(
                refreshToken: refreshToken,
                appIntegrityProvider: appIntegrityProvider
            )
        } catch let error as FirebaseAppCheckError where error.errorType == .network {
            throw RefreshTokenExchangeError.noInternet
        } catch let error as URLError where error.code == .notConnectedToInternet
                    || error.code == .networkConnectionLost {
            throw RefreshTokenExchangeError.noInternet
        } catch let error as ServerError where error.errorCode == 400 {
            NotificationCenter.default.post(name: .accountIntervention)
            throw RefreshTokenExchangeError.accountIntervention
        }
    }
    
    func makeRequest(_ request: URLRequest) async throws -> Data {
        do {
            return try await networkClient.makeRequest(request)
        } catch let error as URLError where error.code == .notConnectedToInternet
                    || error.code == .networkConnectionLost {
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
        } catch let error as URLError where error.code == .notConnectedToInternet
                    || error.code == .networkConnectionLost {
            throw error
        }
    }
}
