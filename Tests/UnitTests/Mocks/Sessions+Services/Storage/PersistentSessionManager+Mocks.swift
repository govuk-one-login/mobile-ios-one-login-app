import Foundation
@testable import OneLogin

extension PersistentSessionManager {
    
    static func make(mockAccessControlEncryptedStore: MockSecureStoreService = MockSecureStoreService(),
                     mockEncryptedStore: MockSecureStoreService = MockSecureStoreService(),
                     mockUnprotectedStore: MockDefaultsStore = MockDefaultsStore(),
                     mockLocalAuthentication: MockLocalAuthManager = MockLocalAuthManager(),
                     mockAnalyticsService: OneLoginAnalyticsService = MockAnalyticsService(),
                     mockWalletSDK: MockWalletSDKWrapper = MockWalletSDKWrapper(),
                     serialTaskQueue: SerialTaskQueue = SerialTaskQueue()) -> PersistentSessionManager {
        
        return PersistentSessionManager(
            accessControlEncryptedStore: mockAccessControlEncryptedStore,
            encryptedStore: mockEncryptedStore,
            unprotectedStore: mockUnprotectedStore,
            localAuthentication: mockLocalAuthentication,
            analyticsService: mockAnalyticsService,
            walletSDK: mockWalletSDK,
            serialTaskQueue: serialTaskQueue
        )
    }
    
    static func resumeSessionPersistentSessionManager(mockAccessControlEncryptedStore: MockSecureStoreService = MockSecureStoreService(),
                    mockEncryptedStore: MockSecureStoreService = MockSecureStoreService(),
                    mockUnprotectedStore: MockDefaultsStore = MockDefaultsStore(),
                    mockLocalAuthentication: MockLocalAuthManager = MockLocalAuthManager(),
                    mockAnalyticsService: OneLoginAnalyticsService = MockAnalyticsService(),
                    mockWalletSDK: MockWalletSDKWrapper = MockWalletSDKWrapper()) throws -> PersistentSessionManager {
        
        mockLocalAuthentication.localAuthIsEnabledOnTheDevice = true
        mockUnprotectedStore.savedData = [OLString.returningUser: true]
        
        // AND I have a persistentSessionID saved in secure store
        try mockEncryptedStore.saveItem(
            item: UUID().uuidString,
            itemName: OLString.persistentSessionID
        )
        
        // AND I have tokens saved in secure store
        let data = StoredTokens.encodeKeys(
            idToken: MockJWTs.genericToken,
            refreshToken: MockJWTs.genericToken,
            accessToken: MockJWTs.genericToken
        )
        try mockAccessControlEncryptedStore.saveItem(
            item: data,
            itemName: OLString.storedTokens
        )
        
        return PersistentSessionManager(
            accessControlEncryptedStore: mockAccessControlEncryptedStore,
            encryptedStore: mockEncryptedStore,
            unprotectedStore: mockUnprotectedStore,
            localAuthentication: mockLocalAuthentication,
            analyticsService: mockAnalyticsService,
            walletSDK: mockWalletSDK
        )

    }
}
