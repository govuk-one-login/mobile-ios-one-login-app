import Foundation

public protocol KeyService {
    var keys: KeyPair? { get }
    func setup() throws
    func deleteKeys() throws
    func signAndVerifyData(data: Data) throws -> Data
    func generateDidKey() throws -> String
}
