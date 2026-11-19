@testable import OneLogin
import Testing
import WalletInterface

extension [TrustedCertificate].CertificateAsset {
    public static func integration(names: String...) -> Self {
        return Self(namespace: "integration", names: names)
    }

    public static func integration(names: [String]) -> Self {
        return Self(namespace: "integration", names: names)
    }
}

struct TrustedCertificateTests {
    @Test
    func test() throws {
        let certificates: [TrustedCertificate] = .load(
            .integration(names: "root-ca-2026-v2.pem")
        )
        
        #expect(certificates.count == 1)
    }
    
    @Test
    func test0() throws {
        let certificates: [TrustedCertificate] = .load(
            .integration(names: "root-ca-2026-v2.pem", "")
        )
        
        #expect(certificates.count == 1)
    }
    
    @Test
    func test2() throws {
        let certificates: [TrustedCertificate] = .load(
            .integration(names: "")
        )
        
        #expect(certificates.count == 0)
    }
    
    @Test
    func test3() throws {
        let certificates: [TrustedCertificate] = .load(
            .integration(names: [])
        )
        
        #expect(certificates.count == 0)
    }
}
