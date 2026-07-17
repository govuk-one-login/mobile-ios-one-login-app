@testable import AppIntegrity
import Testing

struct AppIntegrityErrorTests {
    // swiftlint:disable line_length
    static let allFirebaseAppCheckErrors = [
        (error: FirebaseAppCheckError(.unknown, reason: "unknown firebase app check service error"), debugDescription: "unknown firebase app check service error"),
        (error: FirebaseAppCheckError(.network, reason: "network error in firebase app check service"), debugDescription: "network error in firebase app check service"),
        (error: FirebaseAppCheckError(.invalidConfiguration, reason: "invalid configuration for firebase app check service"), debugDescription: "invalid configuration for firebase app check service"),
        (error: FirebaseAppCheckError(.keychainAccess, reason: "keychain access error in firebase app check service"), debugDescription: "keychain access error in firebase app check service"),
        (error: FirebaseAppCheckError(.notSupported, reason: "firebase app check service not supported on this platform"), debugDescription: "firebase app check service not supported on this platform"),
        (error: FirebaseAppCheckError(.generic, reason: "generic firebase app check service error"), debugDescription: "generic firebase app check service error")

    ]
    
    static let allClientAssertionErrors = [
        (error: ClientAssertionError(.invalidPublicKey, reason: "invalid client attestation public key"), debugDescription: "invalid client attestation public key"),
        (error: ClientAssertionError(.invalidToken, reason: "invalid firebase app check token"), debugDescription: "invalid firebase app check token"),
        (error: ClientAssertionError(.serverError, reason: "server error"), debugDescription: "server error"),
        (error: ClientAssertionError(.cantDecodeClientAssertion, reason: "cant decode client attestation"), debugDescription: "cant decode client attestation")
    ]
    
    static let allProofOfPossessionErrors = [
        (error: ProofOfPossessionError(.cantGenerateAttestationPublicKeyJWK, reason: "cant generate attestation public key JWK"), debugDescription: "cant generate attestation public key JWK"),
        (error: ProofOfPossessionError(.cantGenerateAttestationProofOfPossessionJWT, reason: "cant generate attestation proof of possession JWT"), debugDescription: "cant generate attestation proof of possession JWT"),
        (error: ProofOfPossessionError(.cantGenerateDemonstratingProofOfPossessionJWT, reason: "can't generate demonstrating public key dictionary JWT"), debugDescription: "can't generate demonstrating public key dictionary JWT")
    ]
    // swiftlint:enable line_length

    @Test("assert debugDescription matches reason", arguments: AppIntegrityErrorTests.allFirebaseAppCheckErrors)
    func test_debugDescription(sut: FirebaseAppCheckError, debugDescription: String) async throws {
        #expect(sut.debugDescription == debugDescription)
    }
    
    @Test("assert debugDescription matches reason", arguments: AppIntegrityErrorTests.allClientAssertionErrors)
    func test_debugDescription(sut: ClientAssertionError, debugDescription: String) async throws {
        #expect(sut.debugDescription == debugDescription)
    }

    @Test("assert debugDescription matches reason", arguments: AppIntegrityErrorTests.allProofOfPossessionErrors)
    func test_debugDescription(sut: ProofOfPossessionError, debugDescription: String) async throws {
        #expect(sut.debugDescription == debugDescription)
    }
}
