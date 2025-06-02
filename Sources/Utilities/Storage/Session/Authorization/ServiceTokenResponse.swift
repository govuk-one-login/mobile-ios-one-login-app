import Foundation

struct ServiceTokenResponse: Decodable {
    let accessToken: String
    let tokenType: String
    let expiresIn: Int
}
