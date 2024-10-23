import FirebaseAppCheck
import FirebaseCore
import Networking

enum AppIntegrityError: Int, Error {
    case invalidPublicKey = 400
    case invalidToken = 401
}

enum NotImplementedError: Error {
    case notImplemented
}

public final class FirebaseAppIntegrityService: AppIntegrityProvider {
    private let client: NetworkClient
    private let baseURL: URL
    private let vendor: AppCheckVendor
    private let proofOfPossessionProvider: ProofOfPossessionProvider

    // TODO: DCMAW-10322 | Return true if a valid (non-expired) attestation JWT is available
    private var isValidAttestationAvailable: Bool = false

    private static var providerFactory: AppCheckProviderFactory {
        #if DEBUG
        AppCheckDebugProviderFactory()
        #else
        if #available(iOS 14.0, *) {
            AppAttestProviderFactory()
        } else {
            DeviceCheckProviderFactory()
        }
        #endif
    }

    static func configure(vendorType: AppCheckVendor.Type) {
        vendorType.setAppCheckProviderFactory(providerFactory)
    }

    public static func configure() {
        configure(vendorType: AppCheck.self)
    }

    init(vendor: AppCheckVendor,
         providerFactory: AppCheckProviderFactory,
         proofOfPossessionProvider: ProofOfPossessionProvider,
         client: NetworkClient,
         baseURL: URL) {
        self.client = client
        self.vendor = vendor
        self.baseURL = baseURL
        self.proofOfPossessionProvider = proofOfPossessionProvider
    }

    public convenience init(
        client: NetworkClient,
        baseURL: URL,
        proofOfPossessionProvider: ProofOfPossessionProvider
    ) {
        self.init(
            vendor: AppCheck.appCheck(),
            providerFactory: Self.providerFactory,
            proofOfPossessionProvider: proofOfPossessionProvider,
            client: client,
            baseURL: baseURL
        )
    }

    public func assertIntegrity() async throws -> String {
        guard !isValidAttestationAvailable else {
            // nothing to do:
            throw NotImplementedError.notImplemented
        }

        let token = try await vendor.token(forcingRefresh: false)
        print("vendor token: \(token.token)")

        do {
            let attestation = try await fetchClientAttestation(appCheckToken: token.token)
            // TODO: DCMAW-10322 | store this locally
            return attestation.attestationJWT
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

    public func addIntegrityAssertions(to request: URLRequest) async throws -> URLRequest {
        var signedRequest = request
        signedRequest.addValue("abc",
                               forHTTPHeaderField: "OAuth-Client-Attestation")
        signedRequest.addValue("def",
                               forHTTPHeaderField: "OAuth-Client-Attestation-PoP")
        return signedRequest
    }
}
