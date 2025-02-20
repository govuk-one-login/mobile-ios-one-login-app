@testable import OneLogin
import SecureStore
import Testing

final class OneLoginSecureStoreManagerTests {
    private var mockAccessControlEncryptedStore: MockSecureStoreService!
    private var mockEncryptedStore: MockSecureStoreService!
    private var mockLocalAuthentication: MockLocalAuthManager!
    private var sut: OneLoginSecureStoreManager!
    
    init() {
        mockAccessControlEncryptedStore = MockSecureStoreService()
        mockEncryptedStore = MockSecureStoreService()
        mockLocalAuthentication = MockLocalAuthManager()
        sut = OneLoginSecureStoreManager(
            accessControlEncryptedStore: mockAccessControlEncryptedStore,
            encryptedStore: mockEncryptedStore,
            localAuthentication: mockLocalAuthentication
        )
    }
    
    func convenienceInit() {
        sut = OneLoginSecureStoreManager(
            localAuthentication: mockLocalAuthentication
        )
    }
}

extension OneLoginSecureStoreManagerTests {
    @Test("Ensure convenience initialiser creates instances of SecureStoreService")
    func convenienceInitialiser() {
        convenienceInit()
        #expect(sut.accessControlEncryptedStore is SecureStoreService)
        #expect(sut.encryptedStore is SecureStoreService)
    }
    
    @Test("Ensure delete replaces instances of SecureStorable")
    func delete() throws {
        #expect(sut.accessControlEncryptedStore is MockSecureStoreService)
        #expect(sut.encryptedStore is MockSecureStoreService)
        try sut.delete()
        #expect(mockAccessControlEncryptedStore.didCallDeleteStore)
        #expect(mockEncryptedStore.didCallDeleteStore)
        #expect(sut.accessControlEncryptedStore is SecureStoreService)
        #expect(sut.encryptedStore is SecureStoreService)
    }
}
