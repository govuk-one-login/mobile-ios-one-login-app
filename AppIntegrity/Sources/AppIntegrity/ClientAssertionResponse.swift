import Foundation

struct ClientAssertionResponse: Decodable {
    let attestationJWT: String
    let expiryDate: Date

    enum CodingKeys: String, CodingKey {
        case attestationJWT = "client_attestation"
        case expiresIn = "expires_in"
    }

    init(from decoder: any Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        attestationJWT = try values.decode(String.self, forKey: .attestationJWT)

        let expiresIn = try values.decode(Double.self, forKey: .expiresIn)
        expiryDate = Date(timeIntervalSinceNow: expiresIn)
    }
}
