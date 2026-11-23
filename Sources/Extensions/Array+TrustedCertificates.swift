import GDSUtilities
import UIKit
import WalletInterface
import X509

extension Array where Element == TrustedCertificate {
    public typealias TrustedCertificatesLoadErrorClosure = (TrustedCertificateLoadError) -> Void

    /// The certificate assets found within the `Certificates.xcassets` asset catalogue with an associated `namespace` and
    /// a given `name`.
    ///
    /// - SeeAlso: https://developer.apple.com/documentation/xcode/managing-assets-with-asset-catalogs
    /// - SeeAlso: https://developer.apple.com/videos/play/wwdc2018/227/?time=1997
    public struct CertificateAssets {
        let namespace: String
        /// The names for each of the certificate under the associated ``namespace``
        let names: [String]
        
        /// The ``CertificateAssets`` for the "current" build configuration as returned by ``AppEnvironment/buildConfiguration``.
        public static let current: CertificateAssets = CertificateAssets(
            namespace: AppEnvironment.buildConfiguration,
            names: AppEnvironment.self.trustedCertificateNames
        )
    }
    
    /// Returns an array of ``TrustedCertificate`` for the given `configuration` and `names`.
    ///
    /// The load operation is resiliant and will not abort the load operation when it encounters an error loading one of the certificates.
    /// Any error encountered when loading a certificate, will be reported on the given `onError` closure. The load operation will
    /// continue loading and returns every certificate that it **succesfully** loaded.
    ///
    /// In case you opt-in to error handling, you should ensure that your handling is fast or otherwise or done asyncrhonously
    /// so as not to block the load operation.
    ///
    /// The certificates are **expected** to be encoded in UTF-8 using the **PEM** format.
    ///
    /// - Parameters:
    ///     - bundle: the bundle where the asset catalogue is available in; default ``Bundle.main``.
    ///     - configuration: the configuration the certificates are associated with, e.g. `staging`.
    ///     - names: the file name of the certificate e.g. `foo.pem`.
    ///     - onError: _optional_ a closure that reports an ``TrustedCertificateLoadError`` error in case load fails for a one of the certificates attempted to load.
    /// - SeeAlso: ``TrustedCertificateLoadErrorKind`` on the kind of errors reported while attempting to load a certificate.
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
        _ asset: CertificateAssets = .current,
        onError: TrustedCertificatesLoadErrorClosure? = nil
    ) -> [any TrustedCertificate] {
        return load(
            configuration: asset.namespace,
            names: asset.names,
            onError: onError
        )
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
            .invalidEncoding,
            additionalParameters: ["namespace": namespace, "name": name]
        )
    }

    static func invalidPEM(namespace: String, name: String, underlyingError: any Error) -> Self {
        .init(
            .invalidPEM,
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
            // swiftlint:disable:next line_length
            "The certificate could not be found in the `Certificates.xcassets` asset catalog. Did you forget to put the certifcate in the asset catalog? Double check the name isn't mispelled, including the configuration used as a namespace."
        case .invalidEncoding:
            "The certificate could not be read as UTF-8 encoded. Have you chanced the data is encoded in UTF-8?"
        case .invalidPEM:
            "The certificate could not be parsed in a PEM format. Have you checked that the certificate is not malformed?"
        }
    }
}
