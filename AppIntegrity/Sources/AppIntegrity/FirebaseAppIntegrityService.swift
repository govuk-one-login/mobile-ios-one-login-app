import FirebaseAppCheck
import FirebaseCore
import Networking

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

    // TODO: DCMAW-10322 | Return true if a valid (non-expired) attestation JWT is available
    private var isValidAttestationAvailable: Bool = false

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
                    // error: AttestationStorageError.cantRetrieveAttestationJWT
                    TokenHeaderKey.attestationJWT.rawValue: try attestationStore.attestationJWT,
                    TokenHeaderKey.attestationPoP.rawValue: try attestationPoP
                ]
            }
            
            do {
                let appCheck = try await vendor.limitedUseToken()
                let attestationJWT = try await fetchClientAttestation(appCheckToken: appCheck.token)
                
                return [
                    TokenHeaderKey.attestationJWT.rawValue: attestationJWT,
                    TokenHeaderKey.attestationPoP.rawValue: try attestationPoP
                ]
            } catch let error as NSError where
                        error.domain == AppCheckErrorDomain {
                // available at firebase-ios-sdk/FirebaseAppCheck/Sources/Public/FirebaseAppCheck/FIRAppCheckErrors.h
                switch error.code {
                case 0:
                    throw AppIntegrityError<FirebaseAppCheckError>(.unknown, errorDescription: error.localizedDescription)
                case 1:
                    throw AppIntegrityError<FirebaseAppCheckError>(.network, errorDescription: error.localizedDescription)
                case 2:
                    throw AppIntegrityError<FirebaseAppCheckError>(.invalidConfiguration, errorDescription: error.localizedDescription)
                case 3:
                    throw AppIntegrityError<FirebaseAppCheckError>(.keychainAccess, errorDescription: error.localizedDescription)
                case 4:
                    throw AppIntegrityError<FirebaseAppCheckError>(.notSupported, errorDescription: error.localizedDescription)
                default:
                    throw AppIntegrityError<FirebaseAppCheckError>(.generic, errorDescription: error.localizedDescription)
                }
            } catch let error as ServerError where
                        error.errorCode == 400 {
                throw AppIntegrityError<ClientAssertionError>(.invalidPublicKey, errorDescription: error.localizedDescription)
            } catch let error as ServerError where
                        error.errorCode == 401 {
                // potential for a server error or invalid app check token from mobile backend
                throw AppIntegrityError<ClientAssertionError>(.invalidToken, errorDescription: error.localizedDescription)
            } catch let error as ServerError where
                        error.errorCode == 500 {
                throw AppIntegrityError<ClientAssertionError>(.serverError, errorDescription: error.localizedDescription)
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
                throw AppIntegrityError<ClientAssertionError>(.cantCreateAttestationPoP, errorDescription: error.localizedDescription)
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
    
    func fetchClientAttestation(appCheckToken: String) async throws -> String {
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
            
            return assertionResponse.attestationJWT
        } catch let error as ServerError {
            throw error
        } catch let error as DecodingError {
            throw AppIntegrityError<ClientAssertionError>(.cantDecodeClientAssertion, errorDescription: error.localizedDescription)
        } catch {
            throw AppIntegrityError<ProofOfPossessionError>(.cantGeneratePublicKey, errorDescription: error.localizedDescription)
        }
    }
}
