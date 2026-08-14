@testable import AppIntegrity
import GDSUtilities
import Testing

struct AppIntegrityErrorTests {
    
    struct Case<Kind: GDSErrorKind>: Sendable {
        let error: AppIntegrityError<Kind>
        let debugDescription: String
        let kind: String
    }

    // swiftlint:disable line_length
    static let allFirebaseAppCheckErrors = [
        Case(error: FirebaseAppCheckError(.unknown), debugDescription: "Error Domain=FirebaseAppCheckErrorType Code=1000 \"unknown firebase app check service error\"", kind: "unknown"),
        Case(error: FirebaseAppCheckError(.network), debugDescription: "Error Domain=FirebaseAppCheckErrorType Code=1001 \"network error in firebase app check service\"", kind: "network"),
        Case(error: FirebaseAppCheckError(.invalidConfiguration), debugDescription: "Error Domain=FirebaseAppCheckErrorType Code=1002 \"invalid configuration for firebase app check service\"", kind: "invalidConfiguration"),
        Case(error: FirebaseAppCheckError(.keychainAccess), debugDescription: "Error Domain=FirebaseAppCheckErrorType Code=1003 \"keychain access error in firebase app check service\"", kind: "keychainAccess"),
        Case(error: FirebaseAppCheckError(.notSupported), debugDescription: "Error Domain=FirebaseAppCheckErrorType Code=1004 \"firebase app check service not supported on this platform\"", kind: "notSupported"),
        Case(error: FirebaseAppCheckError(.generic), debugDescription: "Error Domain=FirebaseAppCheckErrorType Code=1005 \"generic firebase app check service error\"", kind: "generic")
    ]
    
    static let allClientAssertionErrors = [
        Case(error: ClientAssertionError(.invalidPublicKey), debugDescription: "Error Domain=ClientAssertionErrorType Code=1001 \"invalid client attestation public key\"", kind: "invalidPublicKey"),
        Case(error: ClientAssertionError(.invalidToken), debugDescription: "Error Domain=ClientAssertionErrorType Code=1002 \"invalid firebase app check token\"", kind: "invalidToken"),
        Case(error: ClientAssertionError(.serverError), debugDescription: "Error Domain=ClientAssertionErrorType Code=2001 \"server error\"", kind: "serverError"),
        Case(error: ClientAssertionError(.cantDecodeClientAssertion), debugDescription: "Error Domain=ClientAssertionErrorType Code=3001 \"cant decode client attestation\"", kind: "cantDecodeClientAssertion")
    ]
    
    static let allProofOfPossessionErrors = [
        Case(error: ProofOfPossessionError(.cantGenerateAttestationPublicKeyJWK), debugDescription: "Error Domain=ProofOfPossessionErrorType Code=1002 \"cant generate attestation public key JWK\"", kind: "cantGenerateAttestationPublicKeyJWK"),
        Case(error: ProofOfPossessionError(.cantGenerateAttestationProofOfPossessionJWT), debugDescription: "Error Domain=ProofOfPossessionErrorType Code=1003 \"cant generate attestation proof of possession JWT\"", kind: "cantGenerateAttestationProofOfPossessionJWT"),
        Case(error: ProofOfPossessionError(.cantGenerateDemonstratingProofOfPossessionJWT), debugDescription: "Error Domain=ProofOfPossessionErrorType Code=1001 \"can't generate demonstrating public key dictionary JWT\"", kind: "cantGenerateDemonstratingProofOfPossessionJWT")
    ]
    // swiftlint:enable line_length

    @Test("assert debugDescription", arguments: AppIntegrityErrorTests.allFirebaseAppCheckErrors)
    func test_debugDescription_FirebaseAppCheckError(testCase: Case<FirebaseAppCheckErrorType>) async throws {
        #expect(testCase.error.debugDescription == testCase.debugDescription)
    }
    
    @Test("assert debugDescription", arguments: AppIntegrityErrorTests.allClientAssertionErrors)
    func test_debugDescription_ClientAssertionError(testCase: Case<ClientAssertionErrorType>) async throws {
        #expect(testCase.error.debugDescription == testCase.debugDescription)
    }

    @Test("assert debugDescription", arguments: AppIntegrityErrorTests.allProofOfPossessionErrors)
    func test_debugDescription_ProofOfPossessionError(testCase: Case<ProofOfPossessionErrorType>) async throws {
        #expect(testCase.error.debugDescription == testCase.debugDescription)
    }

    /// // swiftlint:disable line_length
    /// The `kind` found in the `userInfo` **must** hold a unique String identifier that describes the error as reported on analytics
    /// - Seealso: https://govukverify.atlassian.net/wiki/spaces/DCMAW/pages/3787195450/GOV.UK+One+Login+app+-+Error+handling#App-integrity-check-failures
    /// // swiftlint:enable line_length
    @Test("assert kind", arguments: AppIntegrityErrorTests.allFirebaseAppCheckErrors)
    func test_kind_FirebaseAppCheckError(testCase: Case<FirebaseAppCheckErrorType>) async throws {
        #expect(testCase.error.errorUserInfo["kind"] as? String == testCase.kind)
    }
    
    /// // swiftlint:disable line_length
    /// The `kind` found in the `userInfo` **must** hold a unique String identifier that describes the error as reported on analytics
    /// - Seealso: https://govukverify.atlassian.net/wiki/spaces/DCMAW/pages/3787195450/GOV.UK+One+Login+app+-+Error+handling#App-integrity-check-failures
    /// // swiftlint:enable line_length
    @Test("assert kind", arguments: AppIntegrityErrorTests.allClientAssertionErrors)
    func test_kind_ClientAssertionError(testCase: Case<ClientAssertionErrorType>) async throws {
        #expect(testCase.error.errorUserInfo["kind"] as? String == testCase.kind)
    }

    /// // swiftlint:disable line_length
    /// The `kind` found in the `userInfo` **must** hold a unique String identifier that describes the error as reported on analytics
    /// - Seealso: https://govukverify.atlassian.net/wiki/spaces/DCMAW/pages/3787195450/GOV.UK+One+Login+app+-+Error+handling#App-integrity-check-failures
    /// // swiftlint:enable line_length
    @Test("assert kind", arguments: AppIntegrityErrorTests.allProofOfPossessionErrors)
    func test_kind_ProofOfPossessionError(testCase: Case<ProofOfPossessionErrorType>) async throws {
        #expect(testCase.error.errorUserInfo["kind"] as? String == testCase.kind)
    }
}
