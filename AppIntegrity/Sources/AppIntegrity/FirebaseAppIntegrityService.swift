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
    private let networkClient: NetworkClient
    private let baseURL: URL
    private let vendor: AppCheckVendor
    private let proofOfPossessionProvider: ProofOfPossessionProvider
    private let proofTokenGenerator: ProofTokenGenerator

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
         networkClient: NetworkClient,
         proofOfPossessionProvider: ProofOfPossessionProvider,
         baseURL: URL,
         proofTokenGenerator: ProofTokenGenerator) {
        self.networkClient = networkClient
        self.vendor = vendor
        self.proofOfPossessionProvider = proofOfPossessionProvider
        self.baseURL = baseURL
        self.proofTokenGenerator = proofTokenGenerator
    }
    
    public convenience init(networkClient: NetworkClient,
                            proofOfPossessionProvider: ProofOfPossessionProvider,
                            baseURL: URL,
                            proofTokenGenerator: ProofTokenGenerator) {
        self.init(
            vendor: AppCheck.appCheck(),
            networkClient: networkClient,
            proofOfPossessionProvider: proofOfPossessionProvider,
            baseURL: baseURL,
            proofTokenGenerator: proofTokenGenerator
        )
    }
    
    public func assertIntegrity() async throws -> [String: String] {
        guard !isValidAttestationAvailable else {
            // nothing to do:
            throw NotImplementedError.notImplemented
        }

        let appCheck = try await vendor.token(forcingRefresh: false)

        do {
            // TODO: DCMAW-10322 | store this locally
            let attestation = try await fetchClientAttestation(appCheckToken: appCheck.token)
            let attestationPOP = try proofTokenGenerator.token
            
            return [
                "OAuth-Client-Attestation": attestation.attestationJWT,
                "OAuth-Client-Attestation-PoP": attestationPOP
            ]
            
        } catch let error as ServerError where
                    error.errorCode == 400 {
            throw AppIntegrityError.invalidPublicKey
        } catch let error as ServerError where
                    error.errorCode == 401 {
            throw AppIntegrityError.invalidToken
        }
    }
    
    func fetchClientAttestation(appCheckToken: String) async throws -> ClientAssertionResponse {
        let data = try await networkClient.makeRequest(.clientAttestation(
            baseURL: baseURL,
            token: appCheckToken,
            body: try proofOfPossessionProvider.publicKey
        ))
        
        return try JSONDecoder()
            .decode(ClientAssertionResponse.self, from: data)
    }
}
