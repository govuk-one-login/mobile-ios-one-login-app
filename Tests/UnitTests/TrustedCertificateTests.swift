@testable import OneLogin
import Testing
import WalletInterface

struct TrustedCertificateTests {
    @Test
    func test() throws {
        let certificates: [TrustedCertificate] = try .load(
            configuration: "integration",
            names: ["root-ca-2026-v2.pem"]
        )
        
        #expect(certificates.count == 1)
    }
    
    @Test
    func test0() throws {
        let certificates: [TrustedCertificate] = try .load(
            configuration: "integration",
            names: ["root-ca-2026-v2.pem", ""]
        )
        
        #expect(certificates.count == 1)
    }
    
    @Test
    func test2() throws {
        let certificates: [TrustedCertificate] = try .load(
            configuration: "integration",
            names: [""]
        )
        
        #expect(certificates.count == 0)
    }
    
    @Test
    func test3() throws {
        let certificates: [TrustedCertificate] = try .load(
            configuration: "integration",
            names: []
        )
        
        #expect(certificates.count == 0)
    }
}
