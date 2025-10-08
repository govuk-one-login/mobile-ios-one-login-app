import FirebaseAppCheck
import FirebaseCore
import Networking

public enum TokenHeaderKey: String {
    case attestationJWT = "OAuth-Client-Attestation"
    case attestationProofOfPossession = "OAuth-Client-Attestation-PoP"
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
                    TokenHeaderKey.attestationJWT.rawValue: try attestationStore.attestationJWT,
                    TokenHeaderKey.attestationProofOfPossession.rawValue: try attestationProofOfPossession
                ]
            }
            
            do {
                let appCheck = try await vendor.limitedUseToken()
                let attestation = try await fetchClientAttestation(appCheckToken: appCheck.token)
                
                return [
                    TokenHeaderKey.attestationJWT.rawValue: attestation.attestationJWT,
                    TokenHeaderKey.attestationProofOfPossession.rawValue: try attestationProofOfPossession
                ]
            } catch let error as NSError where
                        error.domain == AppCheckErrorDomain {
                // available at firebase-ios-sdk/FirebaseAppCheck/Sources/Public/FirebaseAppCheck/FIRAppCheckErrors.h
                switch error.code {
                case 0:
                    throw AppIntegrityError<FirebaseAppCheckError>(
                        .unknown,
                        errorDescription: error.localizedDescription
                    )
                case 1:
                    throw AppIntegrityError<FirebaseAppCheckError>(
                        .network,
                        errorDescription: error.localizedDescription
                    )
                case 2:
                    throw AppIntegrityError<FirebaseAppCheckError>(
                        .invalidConfiguration,
                        errorDescription: error.localizedDescription
                    )
                case 3:
                    throw AppIntegrityError<FirebaseAppCheckError>(
                        .keychainAccess,
                        errorDescription: error.localizedDescription
                    )
                case 4:
                    throw AppIntegrityError<FirebaseAppCheckError>(
                        .notSupported,
                        errorDescription: error.localizedDescription
                    )
                default:
                    throw AppIntegrityError<FirebaseAppCheckError>(
                        .generic,
                        errorDescription: error.localizedDescription
                    )
                }
            } catch let error as ServerError where
                        error.errorCode == 400 {
                throw AppIntegrityError<ClientAssertionError>(
                    .invalidPublicKey,
                    errorDescription: error.localizedDescription
                )
            } catch let error as ServerError where
                        error.errorCode == 401 {
                throw AppIntegrityError<ClientAssertionError>(
                    .invalidToken,
                    errorDescription: error.localizedDescription
                )
            } catch let error as ServerError where
                        error.errorCode == 500 {
                throw AppIntegrityError<ClientAssertionError>(
                    .serverError,
                    errorDescription: error.localizedDescription
                )
            }
        }
    }
    
    private var attestationProofOfPossession: String {
        get throws {
            do {
                return try proofTokenGenerator.token
            } catch {
                throw AppIntegrityError<ClientAssertionError>(
                    .cantCreateAttestationProofOfPossession,
                    errorDescription: error.localizedDescription
                )
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
        do {
            let data = try await networkClient.makeRequest(.clientAttestation(
                baseURL: baseURL,
                token: appCheckToken,
                body: try proofOfPossessionProvider.publicKey
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
            throw AppIntegrityError<ClientAssertionError>(
                .cantDecodeClientAssertion,
                errorDescription: error.localizedDescription
            )
        } catch {
            throw AppIntegrityError<ProofOfPossessionError>(
                .cantGeneratePublicKey,
                errorDescription: error.localizedDescription
            )
        }
    }
}
