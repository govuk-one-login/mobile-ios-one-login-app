import AppIntegrity
import Foundation
import MockNetworking
@testable import Networking

extension FirebaseAppIntegrityService {
    public static func makeWithMocks(
        mockVendor: AppCheckVendor = MockAppCheckVendor(),
        attestationProofOfPossessionProvider: ProofOfPossessionProvider = MockProofOfPossessionProvider(),
                     attestationProofOfPossessionTokenGenerator: ProofOfPossessionTokenGenerator = MockProofOfPossessionTokenGenerator(),
                     demonstratingProofOfPossessionTokenGenerator: ProofOfPossessionTokenGenerator = MockProofOfPossessionTokenGenerator(),
                     attestationStore: AttestationStorage = MockAttestationStore(),
                     networkClient: NetworkClient = NetworkClient.mock(),
                     baseURL: URL = URL(string: "https://mobile.account.gov.uk")!
    ) -> FirebaseAppIntegrityService {
        return FirebaseAppIntegrityService(
            vendor: mockVendor,
            attestationProofOfPossessionProvider: attestationProofOfPossessionProvider,
            attestationProofOfPossessionTokenGenerator: attestationProofOfPossessionTokenGenerator,
            demonstratingProofOfPossessionTokenGenerator: demonstratingProofOfPossessionTokenGenerator,
            attestationStore: attestationStore,
            networkClient: networkClient,
            baseURL: baseURL)
    }
}

public extension NetworkClient {
    static func mock() -> NetworkClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        
        return NetworkClient(configuration: configuration)
    }
}
