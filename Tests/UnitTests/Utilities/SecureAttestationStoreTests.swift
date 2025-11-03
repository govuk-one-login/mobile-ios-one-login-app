import AppIntegrity
import Foundation
@testable import OneLogin
import Testing

struct SecureAttestationStoreTests: ~Copyable {
    var mockSecureStore: MockSecureStoreService!
    var sut: SecureAttestationStore!
    
    init() {
        mockSecureStore = MockSecureStoreService()
        sut = SecureAttestationStore(secureStore: mockSecureStore)
    }
    
    deinit {
        mockSecureStore.savedItems.removeAll()
    }
    
    @Test
    func attestationExpired() throws {
        try sut.store(
            clientAttestation: MockJWTs.genericToken,
            attestationExpiry: Date.distantPast
        )
        #expect(!sut.attestationExpired)
    }
    
    @Test
    func attestationNotExpired() throws {
        try sut.store(
            clientAttestation: MockJWTs.genericToken,
            attestationExpiry: Date.distantFuture
        )
        #expect(sut.attestationExpired)
    }
    
    @Test
    func attestationMissing() throws {
        #expect(sut.attestationExpired)
    }
    
    @Test
    func attestationJWT() throws {
        try sut.store(
            clientAttestation: MockJWTs.genericToken,
            attestationExpiry: Date.distantFuture
        )
        #expect(try sut.attestationJWT == MockJWTs.genericToken)
    }
}
