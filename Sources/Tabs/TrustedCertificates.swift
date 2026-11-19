import GDSUtilities
import UIKit
import WalletInterface
import X509

extension Array where Element == TrustedCertificate {
    public typealias TrustedCertificatesLoadErrorClosure = (TrustedCertificateLoadError) -> Void

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
         names: [String] = [],
         onError: TrustedCertificatesLoadErrorClosure? = nil
    ) -> [any TrustedCertificate] {
         return names.compactMap { name in
             guard let certificate = NSDataAsset(name: "\(namespace.lowercased())/\(name)", bundle: bundle) else {
                 onError?(.assetNotFound(namespace: namespace, name: name))
                 return nil
             }

             return (certificate, name)
         }.compactMap { (certificate: NSDataAsset, name: String) in
             guard let pem = String(data: certificate.data, encoding: .utf8) else {
                 onError?(.invalidEncoding(namespace: namespace, name: name))
                 return nil
             }

             return (pem, name)
         }.compactMap { (pem: String, name: String) in
             do {
                 return try Certificate(pemEncoded: pem)
             } catch {
                 onError?(.invalidPEM(namespace: namespace, name: name, underlyingError: error))
                 return nil
             }
         }
     }
    
    public static func load(
        _ asset: CertificateAsset = .current,
        onError: TrustedCertificatesLoadErrorClosure? = nil
    ) -> [any TrustedCertificate] {
        return load(configuration: asset.namespace,
                    names: asset.names,
                    onError: onError)
    }
}

public typealias TrustedCertificateLoadError = OneLoginGDSError<TrustedCertificateLoadErrorKind>

extension TrustedCertificateLoadError {
    static func assetNotFound(namespace: String, name: String) -> Self {
        .init(
            .assetNotFound,
            additionalParameters: ["namespace": namespace, "name": name]
        )
    }

    static func invalidEncoding(namespace: String, name: String) -> Self {
        .init(
            .assetNotFound,
            additionalParameters: ["namespace": namespace, "name": name]
        )
    }

    static func invalidPEM(namespace: String, name: String, underlyingError: any Error) -> Self {
        .init(
            .assetNotFound,
            originalError: underlyingError,
            additionalParameters: ["namespace": namespace, "name": name]
        )
    }
}

public enum TrustedCertificateLoadErrorKind: Int, GDSErrorKind {
    // MARK: Load errors
    case assetNotFound = 1001
    case invalidEncoding = 1002
    case invalidPEM = 1003

    var descrption: String {
        switch self {
        case .assetNotFound:
            // swiftlint:disable line_length
            "The certificate could not be found in the `Certificates.xcassets` asset catalog. Did you forget to put the certifcate in the asset catalog? Double check the name isn't mispelled, including the configuration used as a namespace."
            // swiftlint:enable line_length
        case .invalidEncoding:
            "The certificate could not be read as UTF-8 encoded. Have you chanced the data is encoded in UTF-8?"
        case .invalidPEM:
            "The certificate could not be parsed in a PEM format. Have you checked that the certificate is not malformed?"
        }
    }
}
