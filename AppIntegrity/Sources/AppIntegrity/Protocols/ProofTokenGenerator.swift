/// Generates a Proof of Possession JWT.
/// When called, this engages the `AppIntegrityJWT` values found in the TokenGenerator package and signs the JWT using the CryptoSigningService.

public protocol ProofTokenGenerator {
    var token: String { get throws }
}
