import UIKit
import WalletInterface
import X509

extension Array where Element == TrustedCertificate {    
    /// An certificate asset found within the `Certificates.xcassets` asset catalogue
    ///
    /// - SeeAlso: https://developer.apple.com/documentation/xcode/managing-assets-with-asset-catalogs
    /// - SeeAlso: https://developer.apple.com/videos/play/wwdc2018/227/?time=1997
    public struct CertificateAsset {
        let namespace: String
        let names: [String]
    }
    
    static func load(
         bundle: Bundle = .main,
         configuration namespace: String = AppEnvironment.buildConfiguration.lowercased(),
         names: [String] = []
    ) throws -> [any TrustedCertificate] {
         return try names.compactMap { name in
             NSDataAsset(name: "\(namespace.lowercased())/\(name)", bundle: bundle)
         }.compactMap { certificate in
             String(data: certificate.data, encoding: .utf8)
         }.compactMap { pem in
             try Certificate(pemEncoded: pem)
         }
     }
    
    public static func load(
        _ asset: CertificateAsset
    ) throws -> [any TrustedCertificate] {
        return try load(configuration: asset.namespace, names: asset.names)
    }
}
