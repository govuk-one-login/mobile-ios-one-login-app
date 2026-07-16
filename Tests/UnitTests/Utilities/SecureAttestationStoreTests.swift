import AppIntegrity
import Foundation
@testable import OneLogin
import SecureStore
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
        #expect(sut.attestationExpired)
    }
    
    @Test
    func attestationNotExpired() throws {
        try sut.store(
            clientAttestation: MockJWTs.genericToken,
            attestationExpiry: Date.distantFuture
        )
        #expect(!sut.attestationExpired)
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
    
    @Test
    func nonDateErrorEExpiredAttestation() throws {
        try mockSecureStore.saveItem(
            item: "nonDateString",
            itemName: AttestationStorageKey.attestationExpiry.rawValue
        )
        #expect(sut.attestationExpired)
    }
    
    @Test
    func test_attestionJWT_throwsCantDecryptDataError() async throws {
        let errorFromAttestationJWT = SecureStoreError(.cantDecryptData,
                                                       originalError: NSError(domain: NSOSStatusErrorDomain, code: -50))

        let mockSecureStoreService = MockSecureStoreService()
        try mockSecureStoreService.saveDate(id: AttestationStorageKey.attestationExpiry.rawValue, Date.distantFuture)
        mockSecureStoreService.readItemAsFunction = MockSecureStoreService.errorFromReadItem(errorFromAttestationJWT)
        let sut = SecureAttestationStore(secureStore: mockSecureStoreService)

        let error = await #expect(throws: SecureStoreError.self) {
            try await sut.attestationJWT
        }
        
        #expect(error?.kind == .cantDecryptData)
        
        let originalError = try #require(error?.originalError as? NSError)
        #expect(originalError.code == errSecParam)
        #expect(originalError.code == -50)
    }
    
    /// This is a case where as part of instantiating a `SecureAttestationStore`, on the first call to get the `attestationJWT`,
    /// there is a chance the `secureStore` dependency will throw a
    /// `SecureStoreError(.cantDecryptData, originalError: NSError(domain: NSOSStatusErrorDomain, code: -50))`
    ///
    /// This tests verifies that the `SecureAttestationStore` instanced return by `.make()` does not throw a `SecureStoreError(.cantDecryptData)`
    @Test
    func test_attestionJWT_doesNotThrowCantDecryptdataError() async throws {
        let errorFromAttestationJWT: SecureStoreError = SecureStoreError(.cantDecryptData,
                                                       originalError: NSError(domain: NSOSStatusErrorDomain, code: -50))

        var readItemResult: MockSecureStoreService.ReadItemResult = .error
        
        func readItemAsFunction(itemName: String) throws(SecureStore.SecureStoreError) -> String {
            switch readItemResult {
            case .error:
                throw errorFromAttestationJWT
            case .success:
                return "any"
            }
        }
        
        let mockSecureStoreService = MockSecureStoreService(readItemAsFunction: readItemAsFunction, deleteItemAsFunction: { _ in
            readItemResult = .success
        })
        
        try mockSecureStoreService.saveDate(id: AttestationStorageKey.attestationExpiry.rawValue, Date.distantFuture)
                
        let sut = SecureAttestationStore.make(secureStore: mockSecureStoreService)
        #expect(sut.attestationExpired)

        let error = await #expect(throws: SecureStoreError.self) {
            try await sut.attestationJWT
        }
        
        #expect(error?.kind != .cantDecryptData)
    }
}
