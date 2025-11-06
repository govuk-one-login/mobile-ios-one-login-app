enum OLString {
    // Store IDs
    static let v12TokensStore    = "oneLoginTokens"
    static let v13TokensStore    = "oneLoginTokenStore"
    static let v12TokenInfoStore = "insensitiveTokenInfoStore"
    static let v13TokenInfoStore = "persistentSessionID"
    static let attestationStore  = "attestationStore"

    // Token & Login
    static let refreshTokenExpiry  = "refreshTokenExpiry"
    static let accessTokenExpiry   = "accessTokenExpiry"
    static let storedTokens        = "storedTokens"
    static let persistentSessionID = "persistentSessionID"
    static let returningUser       = "returningUser"
    
    // Universal Link Component
    static let redirect = "redirect"
    static let wallet   = "wallet"
    
    // Release Flags
    static let hasAccessedWalletBefore = "hasAccessedWalletBefore"
    
    // Biometrics
    static let biometricsPrompt = "localAuthPrompted"
}
