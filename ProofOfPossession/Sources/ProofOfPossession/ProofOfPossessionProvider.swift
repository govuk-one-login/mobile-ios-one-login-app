import Foundation

protocol ProofOfPossessionProvider {
    var publicKey: Data { get }
    func sign(data: Data) -> Data
}
