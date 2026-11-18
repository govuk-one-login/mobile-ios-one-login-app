import Foundation
import GDSAnalytics
import WalletInterface
import WalletCryptoSupport

struct CertificateFunction {
    let analyticsService: OneLoginAnalyticsService
    
    func trustedReaderCertificates(
         bundle: Bundle = .main,
         resource: String? = AppEnvironment.trustedReaderCertificateName,
         withExtension resourceExtension: String = "pem"
     ) -> [any TrustedCertificate] {         
         guard let resource,
               let url = bundle.url(forResource: resource, withExtension: resourceExtension),
               let pem = try? String(contentsOf: url, encoding: .utf8)
         else { return [] }

         return TrustedReaderCertificateParser.parse(pems: [pem]) { [analyticsService] error in
             analyticsService.logCrash(error)
         }
     }
    
    func findEnvironment() -> String {
        let environment = AppEnvironment.buildConfiguration.lowercased()
        return environment
    }
}
