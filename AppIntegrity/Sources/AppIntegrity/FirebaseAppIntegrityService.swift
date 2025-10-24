import FirebaseAppCheck
import FirebaseCore
import Networking

public enum AppIntegrityHeaderKey: String {
    case attestation                    = "OAuth-Client-Attestation"
    case attestationProofOfPossession   = "OAuth-Client-Attestation-PoP"
    case demonstratingproofOfPossession = "DPoP"
}

struct AttestationJWT: Codable {
    let confirmation: JWKs

    enum CodingKeys: String, CodingKey {
        case confirmation = "cnf"
    }
}

public final class FirebaseAppIntegrityService: AppIntegrityProvider {
    private let vendor: AppCheckVendor
    private let attestationProofOfPossessionProvider: ProofOfPossessionProvider
    private let attestationProofOfPossessionTokenGenerator: ProofOfPossessionTokenGenerator
    private let demonstratingProofOfPossessionTokenGenerator: ProofOfPossessionTokenGenerator
    private let attestationStore: AttestationStorage
    private let networkClient: NetworkClient
    private let baseURL: URL

    private static var providerFactory: AppCheckProviderFactory {
        #if DEBUG
        AppCheckDebugProviderFactory()
        #else
        AppAttestProviderFactory()
        #endif
    }

    public var signingKeysMatch: Bool {
        do {
            let decoder = JSONDecoder()

            // Check that JWK of our signing key matches the one embedded in the attestation JWT
            let deviceSigningJWK = try attestationProofOfPossessionProvider.publicKey
            let deviceSigningKey = try decoder.decode(JWKs.self, from: deviceSigningJWK).jwk

            let attestationJWT = try attestationStore.attestationJWT
            let body = attestationJWT.split(separator: ".")[1]

            // todo: use URL encoding
            let data = Data(base64Encoded: String(body + "="))!
            
            let decodedJWT = try JSONDecoder()
                .decode(AttestationJWT.self, from: data)
            let expectedSigningKey = decodedJWT.confirmation.jwk

            return deviceSigningKey == expectedSigningKey
        } catch {
            return false
        }
    }

    private var hasValidAttestation: Bool {
        attestationStore.validAttestation && signingKeysMatch
    }

    static func configure(vendorType: AppCheckVendor.Type) {
        vendorType.setAppCheckProviderFactory(providerFactory)
    }

    public static func configure() {
        configure(vendorType: AppCheck.self)
    }

    public var integrityAssertions: [String: String] {
        get async throws {
            guard !hasValidAttestation else {
                return [
                    AppIntegrityHeaderKey.attestation.rawValue: try attestationStore.attestationJWT,
                    AppIntegrityHeaderKey.attestationProofOfPossession.rawValue: try attestationProofOfPossessionToken,
                    AppIntegrityHeaderKey.demonstratingproofOfPossession.rawValue: try demonstratingProofOfPossessionToken
                ]
            }
            
            do {
                let appCheck = try await vendor.limitedUseToken()
                let attestation = try await fetchClientAttestation(appCheckToken: appCheck.token)
                
                return [
                    AppIntegrityHeaderKey.attestation.rawValue: attestation.attestationJWT,
                    AppIntegrityHeaderKey.attestationProofOfPossession.rawValue: try attestationProofOfPossessionToken,
                    AppIntegrityHeaderKey.demonstratingproofOfPossession.rawValue: try demonstratingProofOfPossessionToken
                ]
            } catch let error as NSError where
                        error.domain == AppCheckErrorDomain {
                // available at firebase-ios-sdk/FirebaseAppCheck/Sources/Public/FirebaseAppCheck/FIRAppCheckErrors.h
                switch error.code {
                case 0:
                    throw FirebaseAppCheckError(
                        .unknown,
                        errorDescription: error.localizedDescription
                    )
                case 1:
                    throw FirebaseAppCheckError(
                        .network,
                        errorDescription: error.localizedDescription
                    )
                case 2:
                    throw FirebaseAppCheckError(
                        .invalidConfiguration,
                        errorDescription: error.localizedDescription
                    )
                case 3:
                    throw FirebaseAppCheckError(
                        .keychainAccess,
                        errorDescription: error.localizedDescription
                    )
                case 4:
                    throw FirebaseAppCheckError(
                        .notSupported,
                        errorDescription: error.localizedDescription
                    )
                default:
                    throw FirebaseAppCheckError(
                        .generic,
                        errorDescription: error.localizedDescription
                    )
                }
            } catch let error as ServerError where
                        error.errorCode == 400 {
                throw ClientAssertionError(
                    .invalidPublicKey,
                    errorDescription: error.localizedDescription
                )
            } catch let error as ServerError where
                        error.errorCode == 401 {
                throw ClientAssertionError(
                    .invalidToken,
                    errorDescription: error.localizedDescription
                )
            } catch let error as ServerError where
                        error.errorCode == 500 {
                throw ClientAssertionError(
                    .serverError,
                    errorDescription: error.localizedDescription
                )
            }
        }
    }
    
    private var attestationProofOfPossessionToken: String {
        get throws {
            do {
                return try attestationProofOfPossessionTokenGenerator.token
            } catch {
                throw ProofOfPossessionError(
                    .cantGenerateAttestationProofOfPossessionJWT,
                    errorDescription: error.localizedDescription
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
                    errorDescription: error.localizedDescription
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
        networkClient: NetworkClient,
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
        networkClient: NetworkClient,
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
    
    func fetchClientAttestation(appCheckToken: String) async throws -> ClientAssertionResponse {
        do {
            let data = try await networkClient.makeRequest(.clientAttestation(
                baseURL: baseURL,
                token: appCheckToken,
                body: try attestationProofOfPossessionProvider.publicKey
            ))
            
            let assertionResponse = try JSONDecoder()
                .decode(ClientAssertionResponse.self, from: data)
            
            attestationStore.store(
                assertionJWT: assertionResponse.attestationJWT,
                assertionExpiry: assertionResponse.expiryDate
            )
            
            return assertionResponse
        } catch let error as ServerError {
            throw error
        } catch let error as DecodingError {
            throw ClientAssertionError(
                .cantDecodeClientAssertion,
                errorDescription: error.localizedDescription
            )
        } catch {
            throw ProofOfPossessionError(
                .cantGenerateAttestationPublicKeyJWK,
                errorDescription: error.localizedDescription
            )
        }
    }
}
