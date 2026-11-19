@testable import OneLogin
import Testing
import WalletInterface

extension [TrustedCertificate].CertificateAssets {
    public static func integration(names: String...) -> Self {
        return Self(namespace: "integration", names: names)
    }

    public static func integration(names: [String]) -> Self {
        return Self(namespace: "integration", names: names)
    }
}

struct TrustedCertificateTests {
    @Test
    func givenCertificatePresentAssertCount() {
        let certificates: [TrustedCertificate] = .load(
            .integration(names: "root-ca-2026-v2.pem")
        )
        
        #expect(certificates.count == 1)
    }
    
    @Test
    func givenMissingCertificateNameAssertRemainingCount() {
        let certificates: [TrustedCertificate] = .load(
            .integration(names: "root-ca-2026-v2.pem", "")
        )
        
        #expect(certificates.count == 1)
    }
    
    @Test
    func givenMissingCertificateNameAssertCount() {
        let certificates: [TrustedCertificate] = .load(
            .integration(names: "")
        )
        
        #expect(certificates.count == 0)
    }
    
    @Test
    func givenEmptyNameAssertZeroCount() {
        let certificates: [TrustedCertificate] = .load(
            .integration(names: [])
        )
        
        #expect(certificates.count == 0)
    }
}
