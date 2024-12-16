@testable import AppIntegrity
import Foundation
@testable import OneLogin
import Testing

@Suite(.serialized)
struct UserDefaultsTests {
    let sut: UserDefaults
    
    init() {
        sut = UserDefaults()
    }
    
    @Test("Check that validAttestation is true if valid")
    func validAttestation() {
        sut.set(
            Date.distantFuture,
            forKey: AttestationStorageKey.attestationExpiry.rawValue
        )
        #expect(sut.validAttestation)
    }
    
    @Test("Check that validAttestation is false if outdated")
    func invalidAttestation() {
        sut.set(
            Date.distantPast,
            forKey: AttestationStorageKey.attestationExpiry.rawValue
        )
        #expect(!sut.validAttestation)
    }
    
    @Test("Check that validAttestation is false if missing")
    func missingAttestation() {
        sut.set(
            nil,
            forKey: AttestationStorageKey.attestationExpiry.rawValue
        )
        #expect(!sut.validAttestation)
    }
    
    @Test("Return Attestation if present")
    func returnAttestation() throws {
        sut.set(
            "testAttestation",
            forKey: AttestationStorageKey.attestationJWT.rawValue
        )
        #expect(try sut.attestationJWT == "testAttestation")
    }
    
    @Test("Throw error if Attestation is missing")
    func returnAttestationThrows() throws {
        sut.set(
            nil,
            forKey: AttestationStorageKey.attestationJWT.rawValue
        )
        #expect(throws: AttestationStorageError.cantRetrieveAttestationJWT) {
            try sut.attestationJWT
        }
    }
    
    @Test("Check that stored Attestation info is present")
    func storeAttestationInfo() throws {
        let dateToStore = Date.distantFuture
        sut.store(
            assertionJWT: "testAttestation",
            assertionExpiry: dateToStore
        )
        let attestation = sut.value(forKey: AttestationStorageKey.attestationJWT.rawValue)
        let attestationExpiry = sut.value(forKey: AttestationStorageKey.attestationExpiry.rawValue)
        #expect(attestation as? String == "testAttestation")
        #expect(attestationExpiry as? Date == dateToStore)
    }
}
