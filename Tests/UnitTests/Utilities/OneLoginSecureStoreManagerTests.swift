@testable import OneLogin
import SecureStore
import Testing

struct OneLoginSecureStoreManagerTests {
    private var mockLocalAuthentication: MockLocalAuthManager!
    private var sut: OneLoginSecureStoreManager!
    
    init() throws {
        mockLocalAuthentication = MockLocalAuthManager()
        sut = try OneLoginSecureStoreManager(
            localAuthentication: mockLocalAuthentication
        )
    }
    
    @Test("Ensure convenience initialiser creates instances of SecureStoreService")
    func testConvenienceInitialiser() throws {
        #expect(sut.accessControlEncryptedStore is SecureStoreService)
        #expect(sut.encryptedStore is SecureStoreService)
    }
}
