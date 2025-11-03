enum OLString {
    // Store IDs
    static let oneLoginTokensStore  = "oneLoginTokensStore"
    static let publicTokenInfoStore = "publicTokenInfoStore"
    static let attestationStore     = "attestationStore"
    
    // Universal Link Component
    static let redirect = "redirect"
    static let wallet   = "wallet"
    
    // Release Flags
    static let hasAccessedWalletBefore = "hasAccessedWalletBefore"
    
    // Unprotected store keys
    static let returningUser     = UnprotectedStoreKeyString.returningUser.rawValue
    static let accessTokenExpiry = UnprotectedStoreKeyString.accessTokenExpiry.rawValue
    
    // Encrypted store keys
    static let refreshTokenExpiry  = EncryptedStoreKeyString.refreshTokenExpiry.rawValue
    static let persistentSessionID = EncryptedStoreKeyString.persistentSessionID.rawValue
    
    // Access control encyrpted store keys
    static let storedTokens = AccessControlEncryptedStoreKeyString.storedTokens.rawValue
    
    enum UnprotectedStoreKeyString: String, CaseIterable {
        case accessTokenExpiry
        case returningUser
    }
    
    enum EncryptedStoreKeyString: String, CaseIterable {
        case refreshTokenExpiry
        case persistentSessionID
    }
    
    enum AccessControlEncryptedStoreKeyString: String, CaseIterable {
        case storedTokens
    }
}
