@testable import OneLogin
import Testing
import WalletInterface

struct TrustedCertificateTests {
    @Test("Checks a certificate name is present in asset catalogue for a configuration",
          arguments: [
            ("build", [""], 0),
            ("debug", [""], 0),
            ("staging", [""], 0),
            ("integration", ["root-ca-2026-v2.pem"], 1),
            ("integration", ["root-ca-2026-v2.pem", ""], 1),
            ("integration", [""], 0),
            ("integration", [], 0)
          ]
    )
    func givenCertificatePresent(configuration: String, names: [String], count: Int) {
        let certificates: [TrustedCertificate] = .load(
            configuration: configuration,
            names: names
        )
        #expect(certificates.count == count)
    }
    
    @Test("Checks correct error is thrown for a missing asset",
          arguments: [
            ("build", ["root-ca-2026-v2.pem"]),
            ("debug", ["root-ca-2026-v2.pem"]),
            ("staging", ["root-ca-2026-v2.pem"]),
            ("integration", ["root-ca-2026-v3.pem"])
          ]
    )
    func missingAssetThrowsError(configuration: String, names: [String]) {
        var errorsThrown: [TrustedCertificateLoadError] = []
        
        let certficates: [TrustedCertificate] = .load(
            configuration: configuration,
            names: names,
            onError: { error in
                errorsThrown.append(error)
            }
        )
        
        #expect(certficates.isEmpty)
        #expect(errorsThrown.count == 1)
        #expect(errorsThrown.first?.kind == .assetNotFound)
    }
}

struct TrustedCertificateLoadErrorTests {
    struct Case: Sendable {
        let error: TrustedCertificateLoadError
        let debugDescription: String
        let kind: String
    }
     
    static let allTrustedCertificateLoadErrorCases: [Case] = [
        Case(
            error: TrustedCertificateLoadError(.assetNotFound),
            debugDescription: "Error Domain=TrustedCertificateLoadErrorKind Code=1001 \"assetNotFound\"",
            kind: "assetNotFound"
        ),
        Case(
            error: TrustedCertificateLoadError(.invalidEncoding),
            debugDescription: "Error Domain=TrustedCertificateLoadErrorKind Code=1002 \"invalidEncoding\"",
            kind: "invalidEncoding"
        ),
        Case(
            error: TrustedCertificateLoadError(.invalidPEM),
            debugDescription: "Error Domain=TrustedCertificateLoadErrorKind Code=1003 \"invalidPEM\"",
            kind: "invalidPEM"
        )
    ]
   
    @Test("assert error debug description and kind",
          arguments: TrustedCertificateLoadErrorTests.allTrustedCertificateLoadErrorCases)
    func errorDetails(errorCase: Case) {
        #expect(errorCase.error.debugDescription == errorCase.debugDescription)
        #expect(errorCase.error.errorUserInfo["kind"] as? String == errorCase.kind)
    }
}

struct TrustedCertificateLoadErrorKindTests {
    static let descriptions: [(TrustedCertificateLoadErrorKind, String)] = [
        // swiftlint:disable:next line_length
        (.assetNotFound, "The certificate could not be found in the `Certificates.xcassets` asset catalog. Did you forget to put the certifcate in the asset catalog? Double check the name isn't mispelled, including the configuration used as a namespace."),
        (.invalidEncoding, "The certificate could not be read as UTF-8 encoded. Have you chanced the data is encoded in UTF-8?"),
        (.invalidPEM, "The certificate could not be parsed in a PEM format. Have you checked that the certificate is not malformed?")
    ]

    @Test("Error kind has the correct description", arguments: descriptions)
    func description(kind: TrustedCertificateLoadErrorKind, expected: String) {
        #expect(kind.descrption == expected)
    }
}
