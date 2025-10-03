import FirebaseAppCheck
import FirebaseCore
import Networking

enum AppIntegrityError: Int, Error {
    case invalidPublicKey = 400
    case invalidToken = 401
    case cantDecodeClientAssertion
    case cantCreateAttestationPoP
}

public enum TokenHeaderKey: String {
    case attestationJWT = "OAuth-Client-Attestation"
    case attestationPoP = "OAuth-Client-Attestation-PoP"
}

public final class FirebaseAppIntegrityService: AppIntegrityProvider {
    private let networkClient: NetworkClient
    private let baseURL: URL
    private let vendor: AppCheckVendor
    private let proofOfPossessionProvider: ProofOfPossessionProvider
    private let proofTokenGenerator: ProofTokenGenerator
    private let attestationStore: AttestationStorage

    private static var providerFactory: AppCheckProviderFactory {
        #if DEBUG
        AppCheckDebugProviderFactory()
        #else
        AppAttestProviderFactory()
        #endif
    }

    static func configure(vendorType: AppCheckVendor.Type) {
        vendorType.setAppCheckProviderFactory(providerFactory)
    }

    public static func configure() {
        configure(vendorType: AppCheck.self)
    }
    
    public var integrityAssertions: [String: String] {
        get async throws {
            guard !attestationStore.validAttestation else {
                return [
                    // can only throw AttestationStorageError.cantRetrieveAttestationJWT error
                    TokenHeaderKey.attestationJWT.rawValue: try attestationStore.attestationJWT,
                    TokenHeaderKey.attestationPoP.rawValue: try attestationPoP
                ]
            }
            
            let appCheck = try await vendor.limitedUseToken()
            
            do {
                let attestation = try await fetchClientAttestation(appCheckToken: appCheck.token)
                return [
                    TokenHeaderKey.attestationJWT.rawValue: attestation.attestationJWT,
                    TokenHeaderKey.attestationPoP.rawValue: try attestationPoP
                ]
            } catch let error as ServerError where
                        error.errorCode == 400 {
                throw AppIntegrityError.invalidPublicKey
            } catch let error as ServerError where
                        error.errorCode == 401 {
                throw AppIntegrityError.invalidToken
            }
        }
    }
    
    private var attestationPoP: String {
        get throws {
            do {
                // can throw:
                // JWTGeneratorError.cantCreateJSONData error
                // SigningServiceError.unknownCreateSignatureError error or Security framework error
                return try proofTokenGenerator.token
            } catch {
                throw AppIntegrityError.cantCreateAttestationPoP
            }
        }
    }

    init(vendor: AppCheckVendor,
         networkClient: NetworkClient,
         proofOfPossessionProvider: ProofOfPossessionProvider,
         baseURL: URL,
         proofTokenGenerator: ProofTokenGenerator,
         attestationStore: AttestationStorage) {
        self.networkClient = networkClient
        self.vendor = vendor
        self.proofOfPossessionProvider = proofOfPossessionProvider
        self.baseURL = baseURL
        self.proofTokenGenerator = proofTokenGenerator
        self.attestationStore = attestationStore
    }
    
    public convenience init(networkClient: NetworkClient,
                            proofOfPossessionProvider: ProofOfPossessionProvider,
                            baseURL: URL,
                            proofTokenGenerator: ProofTokenGenerator,
                            attestationStore: AttestationStorage) {
        self.init(
            vendor: AppCheck.appCheck(),
            networkClient: networkClient,
            proofOfPossessionProvider: proofOfPossessionProvider,
            baseURL: baseURL,
            proofTokenGenerator: proofTokenGenerator,
            attestationStore: attestationStore
        )
    }
    
    func fetchClientAttestation(appCheckToken: String) async throws -> ClientAssertionResponse {
        // can throw ServerError
        let data = try await networkClient.makeRequest(.clientAttestation(
            baseURL: baseURL,
            token: appCheckToken,
            // can throw AppIntegritySigningError.publicKeyError error
            body: try proofOfPossessionProvider.publicKey
        ))
        
        do {
            let assertionResponse = try JSONDecoder()
                .decode(ClientAssertionResponse.self, from: data)
            
            attestationStore.store(
                assertionJWT: assertionResponse.attestationJWT,
                assertionExpiry: assertionResponse.expiryDate
            )
            
            return assertionResponse
        } catch {
            throw AppIntegrityError.cantDecodeClientAssertion
        }
    }
}
