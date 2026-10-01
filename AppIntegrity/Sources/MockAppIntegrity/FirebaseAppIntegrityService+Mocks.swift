import AppIntegrity
import Foundation
import MockNetworking
import Networking

extension FirebaseAppIntegrityService {
    public static func makeWithMocks(attestationProofOfPossessionProvider: ProofOfPossessionProvider = MockProofOfPossessionProvider(),
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

public final class MockAppIntegrityNetworkClient: AppIntegrityNetworkClient, NetworkClientProtocol {
    public static func mock() -> MockAppIntegrityNetworkClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: configuration)
        
        return MockAppIntegrityNetworkClient(session: session)
    }

    let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    public func makeRequest(_ request: NetworkRequest) async throws -> Data {
        return try await session.data(for: request.urlRequest).0
    }
    
    public func request(_ request: URLRequest) -> RequestBuilder {
        return RequestBuilder(client: self, request: request)
    }
}
