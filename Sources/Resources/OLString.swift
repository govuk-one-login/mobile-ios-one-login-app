enum OLString {
    /// Store IDs
    ///
    /// The v12 and v13 differences here come from a change in store names.
    /// These values should NOT change without agreed migration to a singular value.
    ///
    /// Original change can be seen here
    /// https://github.com/govuk-one-login/mobile-ios-one-login-app/pull/579/files#diff-36a8fe27d5aaeae29cb4a3668b76bae17e290e25e9aaa41d58e0012b54ed2d67L1-L18
    /// Ticket for the change is here
    /// https://govukverify.atlassian.net/browse/DCMAW-16644
    static let v12TokensStore    = "oneLoginTokens"
    static let v13TokensStore    = "oneLoginTokenStore"
    static let v12TokenInfoStore = "persistentSessionID"
    static let v13TokenInfoStore = "insensitiveTokenInfoStore"
    static let attestationStore  = "attestationStore"

    /// Universal Link Component
    static let redirect = "redirect"
    static let wallet   = "wallet"

    /// Release Flags
    static let hasAccessedWalletBefore = "hasAccessedWalletBefore"

    /// Unprotected store keys
    static let returningUser     = UnprotectedStoreKeyString.returningUser.rawValue
    static let accessTokenExpiry = UnprotectedStoreKeyString.accessTokenExpiry.rawValue
    
    /// Encrypted store keys
    static let refreshTokenExpiry  = EncryptedStoreKeyString.refreshTokenExpiry.rawValue
    static let persistentSessionID = EncryptedStoreKeyString.persistentSessionID.rawValue
    
    /// Access control encyrpted store keys
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
