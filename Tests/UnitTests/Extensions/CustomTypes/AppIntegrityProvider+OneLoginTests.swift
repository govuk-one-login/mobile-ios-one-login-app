@testable import AppIntegrity
import Firebase
import Foundation.NSDate
@testable import OneLogin
import Testing

struct AppIntegrityProviderTests: ~Copyable {
    let store = SecureAttestationStore()

    deinit {
        // TODO: clear the store after
    }

    @Test
    func attestationProofOfPossessionJWTsAreGeneratedOnDemand() async throws {
        // GIVEN I have a valid attestation
        try store.store(clientAttestation: "example.mock.jwt", attestationExpiry: .distantFuture)

        // WHEN I take several moments to login
        let appCheck = try FirebaseAppIntegrityService.firebaseAppCheck()
        try await Task.sleep(seconds: 1)

        // THEN fresh assertion JWTs are generated
        let date = Date()

        let assertions = try await appCheck.integrityAssertions

        // - DPoP JWT was issued _after_ the login attempt finished
        let dpopJWT = try ExampleJWT(
            rawString: #require(assertions[AppIntegrityHeaderKey.demonstratingProofOfPossession.rawValue])
        )
        let issueTime = try #require(dpopJWT.body.iat)
        #expect(Int(date.timeIntervalSince1970) <= issueTime)

        // - PoP JWT will expire more than three minutes _after_ the login attempt
        let popJWT = try ExampleJWT(
            rawString: #require(assertions[AppIntegrityHeaderKey.attestationProofOfPossession.rawValue])
        )
        let expiryTime = try #require(popJWT.body.exp)
        #expect(Int(date.addingTimeInterval(180).timeIntervalSince1970) <= expiryTime)
    }
}

struct ExampleJWT {
    struct Body: Decodable {
        let iat: Int?
        let exp: Int?
    }

    let body: Body

    init(rawString: String) throws {
        let rawBody = rawString
            .components(separatedBy: ".")[1]

        let bodyData = try #require(
            Data(base64URLEncoded: rawBody)
        )

        body = try JSONDecoder()
            .decode(Body.self, from: bodyData)
    }
}
