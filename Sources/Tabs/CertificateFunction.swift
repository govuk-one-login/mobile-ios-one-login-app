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
         // calculate list of urls, where a url is a url pointing to a file
         
         // filter the list of urls by the names defined within the plist (to make sure that the certificate file is being used not a file of another name)
         
         // map each url to string (pem)
         
         // map each string to a certificate
         
         // note - look into dependency to wallet
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
