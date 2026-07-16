import AppIntegrity
import FirebaseAppCheck
import Foundation
import MockNetworking
import Networking
@testable import OneLogin

extension FirebaseAppIntegrityService {
    
    static func makeNonExpired(errorFromAttestationJWT: Error) -> FirebaseAppIntegrityService {
        
        let mockAttestationStore = MockAttestationStore(attestationExpired: false, errorFromAttestationJWT: errorFromAttestationJWT)

        return make(attestationStore: mockAttestationStore)
    }
    
    static func make(attestationProofOfPossessionProvider: ProofOfPossessionProvider = MockProofOfPossessionProvider(),
                     attestationProofOfPossessionTokenGenerator: ProofOfPossessionTokenGenerator = MockProofOfPossessionTokenGenerator(),
                     demonstratingProofOfPossessionTokenGenerator: ProofOfPossessionTokenGenerator = MockProofOfPossessionTokenGenerator(),
                     attestationStore: AttestationStorage = MockAttestationStore(),
                     networkClient: AppIntegrityNetworkClient = MockAppIntegrityNetworkClient.mock(),
                     baseURL: URL = URL(string: "https://mobile.account.gov.uk")!
    ) -> FirebaseAppIntegrityService {
        
        return FirebaseAppIntegrityService(
            vendor: MockAppCheckVendor(),
            attestationProofOfPossessionProvider: attestationProofOfPossessionProvider,
            attestationProofOfPossessionTokenGenerator: attestationProofOfPossessionTokenGenerator,
            demonstratingProofOfPossessionTokenGenerator: demonstratingProofOfPossessionTokenGenerator,
            attestationStore: attestationStore,
            networkClient: networkClient,
            baseURL: baseURL)
    }
}

final class MockProofOfPossessionProvider: ProofOfPossessionProvider {
    
    static func dataFromPublicKey(_ data: Data = Data()) -> PublicKeyAsFunction {
        return { data }
    }

    static func errorFromPublicKey(_ error: Error) -> PublicKeyAsFunction {
        return {
            throw error
        }
    }

    static func dataFromSign(_ data: Data = Data()) -> SignAsFunction {
        return { data }
    }

    typealias SignAsFunction = () -> (Data)
    typealias PublicKeyAsFunction = () throws -> (Data)
    var publicKeyAsFunction: PublicKeyAsFunction
    var signAsFunction: SignAsFunction

    convenience init() {
        self.init(publicKeyAsFunction: Data("""
                {
                  "jwk": {
                    "kty": EC",
                    "use": "sig",
                    "crv": "P-256",
                    "x": "18wHLeIgW9wVN6VD1Txgpqy2LszYkMf6J8njVAibvhM",
                    "y": "-V4dS4UaLMgP_4fY4j8ir7cl1TXlFdAgcx55o7TkcSA"
                  }
                }
            """.utf8), signAsFunction: Data())
    }
    init(publicKeyAsFunction: @escaping @autoclosure PublicKeyAsFunction, signAsFunction: @escaping @autoclosure SignAsFunction) {
        self.publicKeyAsFunction = publicKeyAsFunction
        self.signAsFunction = signAsFunction
    }
    
    var publicKey: Data {
        get throws {
            try publicKeyAsFunction()
        }
    }
    
    func sign(data: Data) -> Data {
        signAsFunction()
    }
}

class MockProofOfPossessionTokenGenerator: ProofOfPossessionTokenGenerator {
    
    static func token(header: [String: Any] = [:], payload: [String: Any] = [:]) -> TokenJWTAsFunction {
        return { "\(header.merging(payload) { $1 })" }
    }

    static func errorFromToken(_ error: Error) -> TokenJWTAsFunction {
        return {
            throw error
        }
    }

    typealias TokenJWTAsFunction = () throws -> (String)
    var tokenAsFunction: TokenJWTAsFunction
    
    convenience init() {
        self.init(tokenAsFunction: Self.token())
    }
    
    convenience init(error: Error) {
        self.init(tokenAsFunction: Self.errorFromToken(error))
    }
    
    init(tokenAsFunction: @escaping TokenJWTAsFunction) {
        self.tokenAsFunction = tokenAsFunction
    }

    var token: String {
        get throws {
            return try tokenAsFunction()
        }
    }
}

class MockAppIntegrityNetworkClient: AppIntegrityNetworkClient, NetworkClientProtocol {
    
    static func mock() -> MockAppIntegrityNetworkClient {
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: configuration)
        
        return MockAppIntegrityNetworkClient(session: session)
    }

    let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func makeRequest(_ request: NetworkRequest) async throws -> Data {
        return try await session.data(for: request.urlRequest).0
    }
    
    func request(_ request: URLRequest) -> RequestBuilder {
        return RequestBuilder(client: self, request: request)
    }
}

class MockAttestationStore: AttestationStorage {
    
    static func attestationJWT(_ attestationJWT: String = "") -> AttestationJWTAsFunction {
        return { attestationJWT }
    }

    static func errorFromAttestationJWT(_ error: Error) -> AttestationJWTAsFunction {
        return {
            throw error
        }
    }

    typealias AttestationJWTAsFunction = () throws -> (String)
    var attestationJWTAsFunction: AttestationJWTAsFunction

    var attestationExpired: Bool = true
    var attestationJWT: String {
        get throws {
            try attestationJWTAsFunction()
        }
    }
    var mockStorage = [String: Any]()

    convenience init(attestationExpired: Bool = false, attestationJWT: String = "", mockStorage: [String: Any] = [String: Any]()) {
        self.init(attestationExpired: attestationExpired, attestationJWTAsFunction: Self.attestationJWT(attestationJWT), mockStorage: mockStorage)
    }

    convenience init(attestationExpired: Bool = false, errorFromAttestationJWT error: Error, mockStorage: [String: Any] = [String: Any]()) {
        self.init(attestationExpired: attestationExpired, attestationJWTAsFunction: Self.errorFromAttestationJWT(error), mockStorage: mockStorage)
    }

    init(attestationExpired: Bool = false, attestationJWTAsFunction: @escaping AttestationJWTAsFunction, mockStorage: [String: Any] = [String: Any]()) {
        self.attestationExpired = attestationExpired
        self.attestationJWTAsFunction = attestationJWTAsFunction
        self.mockStorage = mockStorage
    }

    
    func store(
        clientAttestation assertionJWT: String,
        attestationExpiry assertionExpiry: Date
    ) {
        mockStorage["attestationJWT"] = assertionJWT
        mockStorage["attestationExpiry"] = assertionExpiry
    }
}

final class MockAppCheckVendor: AppCheckVendor {
    static func limitedUseToken(_ appCheckToken: AppCheckToken = AppCheckToken(token: "abc", expirationDate: .distantFuture)) -> LimitedUseTokenAsFunction {
        return { appCheckToken }
    }

    static func errorFromLimitedUseToken(_ error: Error) -> LimitedUseTokenAsFunction {
        return {
            throw error
        }
    }

    private(set) static var factory: (any AppCheckProviderFactory)?

    static func setAppCheckProviderFactory(_ factory: (any AppCheckProviderFactory)?) {
        self.factory = factory
    }
    
    static func appCheck() -> Self {
        guard let vendor = MockAppCheckVendor() as? Self else {
            preconditionFailure("Expected MockAppCheckVendor to conform to AppCheckVendor")
        }
        return vendor
    }
    
    typealias LimitedUseTokenAsFunction = () async throws -> (AppCheckToken)
    var limitedUseTokenAsFunction: LimitedUseTokenAsFunction

    convenience init(appCheckToken: AppCheckToken = AppCheckToken(token: "abc", expirationDate: .distantFuture)) {
        self.init(limitedUseTokenAsFunction: Self.limitedUseToken(appCheckToken))
    }
    
    convenience init(error: Error) {
        self.init(limitedUseTokenAsFunction: Self.errorFromLimitedUseToken(error))
    }
    
    init(limitedUseTokenAsFunction: @escaping LimitedUseTokenAsFunction) {
        self.limitedUseTokenAsFunction = limitedUseTokenAsFunction
    }

    func limitedUseToken() async throws -> AppCheckToken {
        return try await limitedUseTokenAsFunction()
    }
}
