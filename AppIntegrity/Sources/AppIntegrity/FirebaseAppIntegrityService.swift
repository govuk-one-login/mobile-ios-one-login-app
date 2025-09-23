import FirebaseAppCheck
import FirebaseCore
import Networking

public struct AppIntegrityError: Error, LocalizedError, Equatable {
    public enum AppIntegrityErrorType {
        case unknown
        case network
        case invalidConfiguration
        case keychainAccess
        case notSupported
        case generic
        case invalidPublicKey
        case invalidToken
        case serverError
    }
    
    public let errorType: AppIntegrityErrorType
    public var errorDescription: String?
    
    public init(
        _ errorType: AppIntegrityErrorType,
        underlyingReason: String
    ) {
        self.errorType = errorType
        self.errorDescription = underlyingReason
    }
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
                    TokenHeaderKey.attestationJWT.rawValue: try attestationStore.attestationJWT,
                    TokenHeaderKey.attestationPoP.rawValue: try proofTokenGenerator.token
                ]
            }
            
            do {
                let appCheck = try await vendor.limitedUseToken()
                let attestation = try await fetchClientAttestation(appCheckToken: appCheck.token)
                let attestationPOP = try proofTokenGenerator.token
                
                return [
                    TokenHeaderKey.attestationJWT.rawValue: attestation.attestationJWT,
                    TokenHeaderKey.attestationPoP.rawValue: attestationPOP
                ]
            } catch let error as NSError where
                        error.domain == AppCheckErrorDomain {
                // available at firebase-ios-sdk/FirebaseAppCheck/Sources/Public/FirebaseAppCheck/FIRAppCheckErrors.h
                switch error.code {
                case 0:
                    throw AppIntegrityError(.unknown, underlyingReason: error.localizedDescription)
                case 1:
                    throw AppIntegrityError(.network, underlyingReason: error.localizedDescription)
                case 2:
                    throw AppIntegrityError(.invalidToken, underlyingReason: error.localizedDescription)
                case 3:
                    throw AppIntegrityError(.keychainAccess, underlyingReason: error.localizedDescription)
                case 4:
                    throw AppIntegrityError(.notSupported, underlyingReason: error.localizedDescription)
                default:
                    throw AppIntegrityError(.generic, underlyingReason: error.localizedDescription)
                }
            } catch let error as ServerError where
                        error.errorCode == 400 {
                throw AppIntegrityError(.invalidPublicKey, underlyingReason: error.localizedDescription)
            } catch let error as ServerError where
                        error.errorCode == 401 {
                // potential for a server error or invalid app check token from mobile backend
                throw AppIntegrityError(.invalidToken, underlyingReason: error.localizedDescription)
            } catch let error as ServerError where
                        error.errorCode == 500 {
                throw AppIntegrityError(.serverError, underlyingReason: error.localizedDescription)
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
        let data = try await networkClient.makeRequest(.clientAttestation(
            baseURL: baseURL,
            token: appCheckToken,
            body: proofOfPossessionProvider.publicKey
        ))
        
        let assertionResponse = try JSONDecoder()
            .decode(ClientAssertionResponse.self, from: data)
        
        attestationStore.store(
            assertionJWT: assertionResponse.attestationJWT,
            assertionExpiry: assertionResponse.expiryDate
        )
        
        return assertionResponse
    }
}
