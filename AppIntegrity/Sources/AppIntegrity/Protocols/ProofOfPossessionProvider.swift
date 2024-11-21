import Foundation

public protocol ProofOfPossessionProvider {
    var publicKey: Data { get throws }
}
