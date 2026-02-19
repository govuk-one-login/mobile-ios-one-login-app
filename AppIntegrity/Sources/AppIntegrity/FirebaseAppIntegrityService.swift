import FirebaseAppCheck
import FirebaseCore
import Networking

public enum AppIntegrityHeaderKey: String {
    case attestation                    = "OAuth-Client-Attestation"
    case attestationProofOfPossession   = "OAuth-Client-Attestation-PoP"
    case demonstratingProofOfPossession = "DPoP"
}

public protocol AppIntegrityNetworkClient {
    func makeRequest(_ request: URLRequest) async throws -> Data
}

public final class FirebaseAppIntegrityService: AppIntegrityProvider {
    private let vendor: AppCheckVendor
    private let attestationProofOfPossessionProvider: ProofOfPossessionProvider
    private let attestationProofOfPossessionTokenGenerator: ProofOfPossessionTokenGenerator
    private let demonstratingProofOfPossessionTokenGenerator: ProofOfPossessionTokenGenerator
    private let attestationStore: AttestationStorage
    private let networkClient: AppIntegrityNetworkClient
    private let baseURL: URL
    
    private(set) var errorRetries = 0

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
    
    // Can throw FirebaseAppCheckErrors, ClientAssertionErrors, ProofOfPossessionErrors & uncaught ServerErrors
    public var integrityAssertions: [String: String] {
        get async throws {
            guard hasExpiredAttestation else {
                return [
                    AppIntegrityHeaderKey.attestation.rawValue: try attestationStore.attestationJWT,
                    AppIntegrityHeaderKey.attestationProofOfPossession.rawValue: try attestationProofOfPossessionToken,
                    AppIntegrityHeaderKey.demonstratingProofOfPossession.rawValue: try demonstratingProofOfPossessionToken
                ]
            }
            
            do {
                let appCheckToken = try await fetchAppCheckToken()
                let attestationResponse = try await fetchClientAttestation(appCheckToken: appCheckToken.token)
                
                return [
                    AppIntegrityHeaderKey.attestation.rawValue: attestationResponse.clientAttestation,
                    AppIntegrityHeaderKey.attestationProofOfPossession.rawValue: try attestationProofOfPossessionToken,
                    AppIntegrityHeaderKey.demonstratingProofOfPossession.rawValue: try demonstratingProofOfPossessionToken
                ]
            }
        }
    }
    
    public var hasExpiredAttestation: Bool {
        attestationStore.attestationExpired
    }
    
    private var attestationProofOfPossessionToken: String {
        get throws {
            do {
                return try attestationProofOfPossessionTokenGenerator.token
            } catch {
                throw ProofOfPossessionError(
                    .cantGenerateAttestationProofOfPossessionJWT,
                    originalError: error
                )
            }
        }
    }
    
    private var demonstratingProofOfPossessionToken: String {
        get throws {
            do {
                return try demonstratingProofOfPossessionTokenGenerator.token
            } catch {
                throw ProofOfPossessionError(
                    .cantGenerateDemonstratingProofOfPossessionJWT,
                    originalError: error
                )
            }
        }
    }
    
    init(
        vendor: AppCheckVendor,
        attestationProofOfPossessionProvider: ProofOfPossessionProvider,
        attestationProofOfPossessionTokenGenerator: ProofOfPossessionTokenGenerator,
        demonstratingProofOfPossessionTokenGenerator: ProofOfPossessionTokenGenerator,
        attestationStore: AttestationStorage,
        networkClient: AppIntegrityNetworkClient,
        baseURL: URL
    ) {
        self.vendor = vendor
        self.attestationProofOfPossessionProvider = attestationProofOfPossessionProvider
        self.attestationProofOfPossessionTokenGenerator = attestationProofOfPossessionTokenGenerator
        self.demonstratingProofOfPossessionTokenGenerator = demonstratingProofOfPossessionTokenGenerator
        self.attestationStore = attestationStore
        self.networkClient = networkClient
        self.baseURL = baseURL
    }
    
    public convenience init(
        attestationProofOfPossessionProvider: ProofOfPossessionProvider,
        attestationProofOfPossessionTokenGenerator: ProofOfPossessionTokenGenerator,
        demonstratingProofOfPossessionTokenGenerator: ProofOfPossessionTokenGenerator,
        attestationStore: AttestationStorage,
        networkClient: AppIntegrityNetworkClient,
        baseURL: URL
    ) {
        self.init(
            vendor: AppCheck.appCheck(),
            attestationProofOfPossessionProvider: attestationProofOfPossessionProvider,
            attestationProofOfPossessionTokenGenerator: attestationProofOfPossessionTokenGenerator,
            demonstratingProofOfPossessionTokenGenerator: demonstratingProofOfPossessionTokenGenerator,
            attestationStore: attestationStore,
            networkClient: networkClient,
            baseURL: baseURL
        )
    }
    
    func fetchAppCheckToken() async throws -> AppCheckToken {
        do {
            let appCheckToken = try await vendor.limitedUseToken()
            return appCheckToken
        } catch let error as NSError where
                    error.domain == AppCheckErrorDomain {
            // available at firebase-ios-sdk/FirebaseAppCheck/Sources/Public/FirebaseAppCheck/FIRAppCheckErrors.h
            switch error.code {
            case 0:
                throw FirebaseAppCheckError(
                    .unknown,
                    originalError: error
                )
            case 1:
                errorRetries += 1
                
                guard errorRetries < 3 else {
                    throw FirebaseAppCheckError(
                        .network,
                        originalError: error
                    )
                }
                
                Task {
                    try await Task.sleep(nanoseconds: 100_000_000 * UInt64(errorRetries))
                }
                return try await fetchAppCheckToken()
            case 2:
                throw FirebaseAppCheckError(
                    .invalidConfiguration,
                    originalError: error
                )
            case 3:
                throw FirebaseAppCheckError(
                    .keychainAccess,
                    originalError: error
                )
            case 4:
                throw FirebaseAppCheckError(
                    .notSupported,
                    originalError: error
                )
            default:
                throw FirebaseAppCheckError(
                    .generic,
                    originalError: error
                )
            }
        }
    }
    
    func fetchClientAttestation(appCheckToken: String) async throws -> ClientAttestationResponse {
        do {
            let data = try await networkClient.makeRequest(.clientAttestation(
                baseURL: baseURL,
                token: appCheckToken,
                body: try attestationProofOfPossessionProvider.publicKey
            ))
            
            let attestationResponse = try JSONDecoder()
                .decode(ClientAttestationResponse.self, from: data)
            
            try attestationStore.store(
                clientAttestation: attestationResponse.clientAttestation,
                attestationExpiry: attestationResponse.expiryDate
            )
            
            return attestationResponse
        } catch let error as ServerError where
                    error.errorCode == 400 {
            throw ClientAssertionError(
                .invalidPublicKey,
                originalError: error
            )
        } catch let error as ServerError where
                    error.errorCode == 401 /* .invalidToken */ ||
                    error.errorCode == 500 /* .serverError */ {
            return try await handleClientAttestationError(error, appCheckToken)
        } catch let error as ServerError {
            throw error
        } catch let error as DecodingError /* .cantDecodeClientAssertion */ {
            return try await handleClientAttestationError(error, appCheckToken)
        } catch {
            throw ProofOfPossessionError(
                .cantGenerateAttestationPublicKeyJWK,
                originalError: error
            )
        }
    }
    
    private func handleClientAttestationError(
        _ error: Error,
        _ appCheckToken: String
    ) async throws -> ClientAttestationResponse {
        errorRetries += 1
        
        guard errorRetries < 3 else {
            throw ProofOfPossessionError(
                .cantGenerateAttestationPublicKeyJWK,
                originalError: error
            )
        }
        
        Task {
            try await Task.sleep(nanoseconds: 10)
        }
        return try await fetchClientAttestation(appCheckToken: appCheckToken)
    }
}
