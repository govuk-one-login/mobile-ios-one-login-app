import Foundation
@testable import OneLogin

extension StoredTokens {
    static func encodeKeys(
        idToken: String,
        refreshToken: String?,
        accessToken: String
    ) -> String {
        let storedTokens = StoredTokens(
            idToken: idToken,
            refreshToken: refreshToken,
            accessToken: accessToken,
            accessTokenExpiry: Date.distantFuture
        )
        
        var keysAsData = String()
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .sortedKeys
            keysAsData = try encoder.encode(storedTokens).base64EncodedString()
        } catch {
            print("error")
        }
        return keysAsData
    }
}
