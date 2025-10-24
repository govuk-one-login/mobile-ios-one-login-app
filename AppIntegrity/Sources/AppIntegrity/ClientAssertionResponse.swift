import Foundation

struct ClientAssertionResponse: Decodable {
    let clientAttestation: String
    let expiresIn: String
}
