import AppIntegrity
import Foundation.NSDate
@testable import OneLogin
import Testing

struct AppIntegrityProviderTests {
    @Test
    func attestationProofOfPossessionJWTsAreGeneratedOnDemand() async throws {
        let appCheck = try FirebaseAppIntegrityService.firebaseAppCheck()

        let date = Date()

        let assertions = try await appCheck.integrityAssertions

        // TODO: assert that date is before assertion timestamp
        // (this TEST should fail on main)
    }
}
