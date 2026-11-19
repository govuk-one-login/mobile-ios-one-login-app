import UIKit
import WalletInterface
import X509

extension Array where Element == TrustedCertificate {    
    /// An certificate asset found within the `Certificates.xcassets` asset catalogue
    ///
    /// - SeeAlso: https://developer.apple.com/documentation/xcode/managing-assets-with-asset-catalogs
    /// - SeeAlso: https://developer.apple.com/videos/play/wwdc2018/227/?time=1997
    public struct CertificateAsset {
        public static let current: CertificateAsset = CertificateAsset(namespace: AppEnvironment.buildConfiguration, names: AppEnvironment.self.trustedCertificateNames)
        let namespace: String
        let names: [String]
    }
    
    static func load(
         bundle: Bundle = .main,
         configuration namespace: String = AppEnvironment.buildConfiguration.lowercased(),
         names: [String] = []
    ) -> [any TrustedCertificate] {
         return names.compactMap { name in
             NSDataAsset(name: "\(namespace.lowercased())/\(name)", bundle: bundle)
         }.compactMap { certificate in
             String(data: certificate.data, encoding: .utf8)
         }.compactMap { pem in
             try? Certificate(pemEncoded: pem)
         }
     }
    
    public static func load(
        _ asset: CertificateAsset = .current
    ) -> [any TrustedCertificate] {
        return load(configuration: asset.namespace, names: asset.names)
    }
}
