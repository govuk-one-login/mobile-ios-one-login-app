enum OLString {
    // Store IDs
    static let oneLoginTokensStore  = "oneLoginTokensStore"
    static let publicTokenInfoStore = "publicTokenInfoStore"
    static let attestationStore     = "attestationStore"

    // Token & Login
    static let refreshTokenExpiry  = UDKeyStrings.refreshTokenExpiry.rawValue
    static let accessTokenExpiry   = UDKeyStrings.accessTokenExpiry.rawValue
    static let storedTokens        = UDKeyStrings.storedTokens.rawValue
    static let persistentSessionID = UDKeyStrings.persistentSessionID.rawValue
    static let returningUser       = UDKeyStrings.returningUser.rawValue
    
    // Universal Link Component
    static let redirect = "redirect"
    static let wallet   = "wallet"
    
    // Release Flags
    static let hasAccessedWalletBefore = "hasAccessedWalletBefore"
    
    // Biometrics
    static let biometricsPrompt = UDKeyStrings.localAuthPrompted.rawValue
    
    enum UDKeyStrings: String, CaseIterable {
        case refreshTokenExpiry
        case accessTokenExpiry
        case storedTokens
        case persistentSessionID
        case returningUser
        case localAuthPrompted
    }
}
