import AppIntegrity
import Foundation
import MockNetworking
import Networking

extension FirebaseAppIntegrityService {
    public static func makeWithMocks(
        mockVendor: AppCheckVendor = MockAppCheckVendor(),
        attestationProofOfPossessionProvider: ProofOfPossessionProvider = MockProofOfPossessionProvider(),
                     attestationProofOfPossessionTokenGenerator: ProofOfPossessionTokenGenerator = MockProofOfPossessionTokenGenerator(),
                     demonstratingProofOfPossessionTokenGenerator: ProofOfPossessionTokenGenerator = MockProofOfPossessionTokenGenerator(),
                     attestationStore: AttestationStorage = MockAttestationStore(),
                     networkClient: any NetworkClientProtocol & AppIntegrityNetworkClient,
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
