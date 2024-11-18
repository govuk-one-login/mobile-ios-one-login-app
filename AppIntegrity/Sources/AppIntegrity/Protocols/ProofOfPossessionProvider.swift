import Foundation

public protocol ProofOfPossessionProvider {
    var publicKey: Data { get }
    func sign(data: Data) -> Data
}
