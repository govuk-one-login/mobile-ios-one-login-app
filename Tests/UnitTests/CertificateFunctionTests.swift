@testable import OneLogin
import Testing

struct CertificateFunctionTests {
    @Test
    func test() {
        let analyticsService: OneLoginAnalyticsService = MockAnalyticsService()
        
        let sut = CertificateFunction(analyticsService: analyticsService)
        let certificates = sut.trustedReaderCertificates()
        
        #expect(certificates.count == 1)
    }
}
