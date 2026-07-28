@testable import AppIntegrity
import Testing

struct AppIntegrityErrorTests {
    // swiftlint:disable line_length
    static let allFirebaseAppCheckErrors = [
        (error: FirebaseAppCheckError(.unknown), debugDescription: "Error Domain=FirebaseAppCheckErrorType Code=1000 \"unknown firebase app check service error\""),
        (error: FirebaseAppCheckError(.network), debugDescription: "Error Domain=FirebaseAppCheckErrorType Code=1001 \"network error in firebase app check service\""),
        (error: FirebaseAppCheckError(.invalidConfiguration), debugDescription: "Error Domain=FirebaseAppCheckErrorType Code=1002 \"invalid configuration for firebase app check service\""),
        (error: FirebaseAppCheckError(.keychainAccess), debugDescription: "Error Domain=FirebaseAppCheckErrorType Code=1003 \"keychain access error in firebase app check service\""),
        (error: FirebaseAppCheckError(.notSupported), debugDescription: "Error Domain=FirebaseAppCheckErrorType Code=1004 \"firebase app check service not supported on this platform\""),
        (error: FirebaseAppCheckError(.generic), debugDescription: "Error Domain=FirebaseAppCheckErrorType Code=1005 \"generic firebase app check service error\"")

    ]
    
    static let allClientAssertionErrors = [
        (error: ClientAssertionError(.invalidPublicKey), debugDescription: "Error Domain=ClientAssertionErrorType Code=1001 \"invalid client attestation public key\""),
        (error: ClientAssertionError(.invalidToken), debugDescription: "Error Domain=ClientAssertionErrorType Code=1002 \"invalid firebase app check token\""),
        (error: ClientAssertionError(.serverError), debugDescription: "Error Domain=ClientAssertionErrorType Code=2001 \"server error\""),
        (error: ClientAssertionError(.cantDecodeClientAssertion), debugDescription: "Error Domain=ClientAssertionErrorType Code=3001 \"cant decode client attestation\"")
    ]
    
    static let allProofOfPossessionErrors = [
        (error: ProofOfPossessionError(.cantGenerateAttestationPublicKeyJWK), debugDescription: "Error Domain=ProofOfPossessionErrorType Code=1002 \"cant generate attestation public key JWK\""),
        (error: ProofOfPossessionError(.cantGenerateAttestationProofOfPossessionJWT), debugDescription: "Error Domain=ProofOfPossessionErrorType Code=1003 \"cant generate attestation proof of possession JWT\""),
        (error: ProofOfPossessionError(.cantGenerateDemonstratingProofOfPossessionJWT), debugDescription: "Error Domain=ProofOfPossessionErrorType Code=1001 \"can't generate demonstrating public key dictionary JWT\"")
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
