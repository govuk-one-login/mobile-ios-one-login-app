enum OLString {
    // Token & Login
    static let refreshTokenExpiry = "refreshTokenExpiry"
    static let accessTokenExpiry  = "accessTokenExpiry"
    static let storedTokens       = "storedTokens"
    static let oneLoginTokens     = "oneLoginTokens"
    static let encryptedStore     = "encryptedStore"
    static let returningUser      = "returningUser"
    static let attestationStore   = "attestationStore"
    static let attestation        = "attestation"
    
    // Universal Link Component
    static let redirect                = "redirect"
    static let wallet                  = "wallet"
    static let hasAccessedWalletBefore = "hasAccessedWalletBefore"
    
    // Biometrics
    static let biometricsPrompt = "localAuthPrompted"
}
