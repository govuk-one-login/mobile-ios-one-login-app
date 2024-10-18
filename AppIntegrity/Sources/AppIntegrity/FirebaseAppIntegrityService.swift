import FirebaseAppCheck
import FirebaseCore
import Networking

enum AppIntegrityError: Int, Error {
    case invalidPublicKey = 400
    case invalidToken = 401
}

public final class FirebaseAppIntegrityService: AppIntegrityProvider {
    private let client: NetworkClient
    private let baseURL: URL
    private let vendor: AppCheckVendor
    private let proofOfPossessionProvider: ProofOfPossessionProvider

    // TODO: DCMAW-10322 | Return true if a valid (non-expired) attestation JWT is available
    private var isValidAttestationAvailable: Bool = false

    init(vendorType: AppCheckVendor.Type,
         providerFactory: AppCheckProviderFactory,
         proofOfPossessionProvider: ProofOfPossessionProvider,
         client: NetworkClient,
         baseURL: URL) {
        vendorType.setAppCheckProviderFactory(providerFactory)
        self.client = client
        self.vendor = vendorType.appCheck()
        self.baseURL = baseURL
        self.proofOfPossessionProvider = proofOfPossessionProvider
    }

    public convenience init(
        client: NetworkClient,
        baseURL: URL,
        proofOfPossessionProvider: ProofOfPossessionProvider
    ) {
        #if DEBUG
        let providerFactory = AppCheckDebugProviderFactory()
        #else
        let providerFactory = AppAttestProviderFactory()
        #endif
        self.init(
            vendorType: AppCheck.self,
            providerFactory: providerFactory,
            proofOfPossessionProvider: proofOfPossessionProvider,
            client: client,
            baseURL: baseURL
        )
    }

    func assertIntegrity() async throws {
        guard !isValidAttestationAvailable else {
            // nothing to do:
            return
        }

        let token = try await vendor.token(forcingRefresh: false)

        do {
            let attestation = try await fetchClientAttestation(appCheckToken: token.token)
            // TODO: DCMAW-10322 | store this locally
        } catch let error as ServerError where
                    error.errorCode == 400 {
            throw AppIntegrityError.invalidPublicKey
        } catch let error as ServerError where
                    error.errorCode == 401 {
            throw AppIntegrityError.invalidToken
        }
    }
    
    func fetchClientAttestation(appCheckToken: String) async throws -> ClientAssertionResponse {
        let data = try await client.makeRequest(.clientAttestation(
            baseURL: baseURL,
            token: appCheckToken,
            body: proofOfPossessionProvider.publicKey
        ))
        return try JSONDecoder()
            .decode(ClientAssertionResponse.self, from: data)
    }

    public func addIntegrityAssertions(to request: URLRequest) -> URLRequest {
        var signedRequest = request
        signedRequest.addValue("abc",
                               forHTTPHeaderField: "OAuth-Client-Attestation")
        signedRequest.addValue("def",
                               forHTTPHeaderField: "OAuth-Client-Attestation-PoP")
        return signedRequest
    }
}
