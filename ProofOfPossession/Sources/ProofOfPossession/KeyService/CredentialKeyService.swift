import BigInt
import CryptoKit
import Foundation

public enum KeyError: Error {
    /// The public key could not be created
    case couldNotCreatePublicKey

    /// The key pair could not be fetched from the keychain
    case couldNotFetchKeyPair

    /// The signature verification failed
    case unableToVerifySignature

    /// This method is not supported on the current OS version
    case unsupportedOS

    /// No result was returned but no error was thrown by the `Security` framework
    case unknown
}

final class CredentialKeyService: KeyService {
    var keys: KeyPair?

    func setup() throws {
        let privateKey = try getPrivateKey()

        guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
            throw KeyError.couldNotCreatePublicKey
        }

        self.keys = .init(publicKey: publicKey, privateKey: privateKey)
    }

    func signAndVerifyData(data: Data) throws -> Data {
        guard let privateKey = keys?.privateKey,
              let publicKey = keys?.publicKey else {
            throw KeyError.couldNotFetchKeyPair
        }

        var error: Unmanaged<CFError>?

        if #available(iOS 17.0, *) {
            guard let signature = SecKeyCreateSignature(privateKey,
                                                        .ecdsaSignatureMessageRFC4754SHA256,
                                                        data as CFData,
                                                        &error) as Data? else {
                guard let error = error?.takeRetainedValue() as? Error else {
                    throw KeyError.unknown
                }
                throw error
            }

            let dataAsCFData = data as CFData
            let signatureAsCFData = signature as CFData

            guard SecKeyVerifySignature(publicKey,
                                        .ecdsaSignatureMessageRFC4754SHA256,
                                        dataAsCFData,
                                        signatureAsCFData,
                                        nil) else {
                throw KeyError.unableToVerifySignature
            }
            return signature
        } else {
            // Fallback on earlier versions
            throw KeyError.unsupportedOS
        }
    }

    /// query to get the private key from the keychain if it already exists
    func getPrivateKey() throws -> SecKey {
        let privateKeyTag = Data("OpenIDPrivateKey".utf8)

        let privateQuery: NSDictionary = [
            kSecClass: kSecClassKey,
            kSecAttrApplicationTag as String: privateKeyTag,
            kSecAttrKeyType: kSecAttrKeyTypeEC,
            kSecReturnRef as String: true
        ]

        var privateKey: CFTypeRef?
        let privateStatus = SecItemCopyMatching(privateQuery as CFDictionary, &privateKey)

        guard privateStatus == errSecSuccess else {
            return try createPrivateKey()
        }

        // swiftlint:disable:next force_cast
        return privateKey as! SecKey
    }

    func createPrivateKey() throws -> SecKey {
        let privateKeyTag = Data("OpenIDPrivateKey".utf8)

        var accessError: Unmanaged<CFError>?

        #if targetEnvironment(simulator)
        let requirement: SecAccessControlCreateFlags = []
        #else
        let requirement: SecAccessControlCreateFlags = [.privateKeyUsage, .biometryCurrentSet, .or, .devicePasscode]
        #endif

        /// adds local auth requirements for when the private key is created
        guard let access = SecAccessControlCreateWithFlags(kCFAllocatorDefault,
                                                           kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                                                           requirement,
                                                           &accessError) else {
            guard let error = accessError?.takeRetainedValue() as? Error else {
                throw KeyError.unknown
            }
            throw error
        }

        let attributes: NSDictionary = [
            kSecAttrKeyType: kSecAttrKeyTypeEC,
            kSecAttrKeySizeInBits: 256,
            kSecAttrTokenID: kSecAttrTokenIDSecureEnclave,
            kSecPrivateKeyAttrs: [
                kSecAttrIsPermanent: true,
                kSecAttrApplicationTag: privateKeyTag,
                kSecAttrAccessControl: access
            ]
        ]

        var error: Unmanaged<CFError>?

        guard let privateKey = SecKeyCreateRandomKey(attributes, &error) else {
            guard let error = error?.takeRetainedValue() as? Error else {
                throw KeyError.unknown
            }
            throw error
        }
        return privateKey
    }

    func deleteKeys() throws {
        let tag = Data("OpenIDPrivateKey".utf8)
        let addquery: [String: Any] = [kSecClass as String: kSecClassKey,
                                       kSecAttrApplicationTag as String: tag]

        _ = SecItemDelete(addquery as CFDictionary)
    }

    /// Key compression eliminates redundant or unnecessary characters from the key data.
    /// A compressed key is a 32 byte value for the x coordinate prepended with 02 or a 03 to represent when y is even (02) or odd (03).
    /// Swift provides a function to do this but it is only available in iOS 16+.
    /// So this function is required for devices running older OS versions.
    ///
    /// - Parameters:
    ///     - publicKeyData: The key to be compressed
    func manuallyGenerateCompressedKey(publicKeyData: Data) -> Data {
        let publicKeyUInt8 = [UInt8](publicKeyData)
        let publicKeyXCoordinate = publicKeyUInt8[1...32]
        let prefix: UInt8 = 2 + (publicKeyData[publicKeyData.count - 1] & 1)
        let mutableXCoordinateArrayUInt8 = [UInt8](publicKeyXCoordinate)
        let prefixArray = [prefix]
        return Data(prefixArray + mutableXCoordinateArrayUInt8)
    }

    /// Returns a did:key representation of the wallet ownership key.
    /// did:key is a format for representing a public key. Specification:  https://w3c-ccg.github.io/did-method-key/
    func generateDidKey() throws -> String {
        guard let secPublicKey = keys?.publicKey,
              let publicKey = SecKeyCopyExternalRepresentation(secPublicKey, nil) else {
            throw KeyError.couldNotFetchKeyPair
        }

        let publicKeyData = publicKey as Data
        var compressedKey: Data

        if #available(iOS 16.0, *) {
            let p256PublicKey = try P256.Signing.PublicKey(x963Representation: publicKeyData)
            compressedKey = p256PublicKey.compressedRepresentation
        } else {
            compressedKey = manuallyGenerateCompressedKey(publicKeyData: publicKeyData)
        }

        let multicodecPrefix: [UInt8] = [0x80, 0x24] // P-256 elliptic curve
        let multicodecData = multicodecPrefix + compressedKey

        let base58Data = encodeBase58(Data(multicodecData))

        let didKey = "did:key:z" + base58Data

        return didKey
    }

    func encodeBase58(_ data: Data) -> String {
        var bigInt = BigUInt(data)
        let base58 = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
        var result = ""

        while bigInt > 0 {
            let (quotient, remainder) = bigInt.quotientAndRemainder(dividingBy: 58)
            result = String(base58[String.Index(utf16Offset: Int(remainder), in: base58)]) + result
            bigInt = quotient
        }

        for byte in data {
            if byte != 0x00 {
                break
            }
            result = "1" + result
        }
        return result
    }
}
