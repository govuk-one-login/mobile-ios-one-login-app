import AppIntegrity
import Authentication
import Foundation
import Networking

protocol TokenExchangeManaging {
    func getUpdatedTokens(
        refreshToken: String
    ) async throws -> TokenResponse
}

final class RefreshTokenExchangeManager: TokenExchangeManaging {
    let networkClient: NetworkClient
    
    convenience init() {
        let networkClient = NetworkClient()
        networkClient.clientAttestationProvider = OneLoginAppIntegrityService(integrityService: FirebaseAppIntegrityService.firebaseAppCheck)
        networkClient.dPoPProvider = OneLoginAppIntegrityService(integrityService: FirebaseAppIntegrityService.firebaseAppCheck)
        self.init(networkClient: networkClient)
    }
    
    init(networkClient: NetworkClient) {
        assert(networkClient.clientAttestationProvider != nil)
        assert(networkClient.dPoPProvider != nil)
        self.networkClient = networkClient
    }
    
    func getUpdatedTokens(
        refreshToken: String
    ) async throws -> TokenResponse {
        do {
            let exchangeResponse = try await networkClient
                .request(
                    .refreshTokenExchange(
                        token: refreshToken
                    )
                )
                .withClientAttestation()
                .withDPoP()
                .execute()
            
            return try JSONDecoder()
                .decode(TokenResponse.self, from: exchangeResponse)
        } catch let error as ServerError where error.errorCode == 400 {
            NotificationCenter.default.post(name: .accountIntervention)
            throw error
        } catch let error as URLError where error.code == .notConnectedToInternet
                    || error.code == .networkConnectionLost || error.code == .timedOut {
            // Transformed to enable offline wallet
            throw RefreshTokenExchangeError.noInternet
        } catch is FirebaseAppCheckError, is ClientAssertionError, is ProofOfPossessionError {
            // All treated as unrecoverable
            throw RefreshTokenExchangeError.appIntegrityFailed
        }
    }
}
