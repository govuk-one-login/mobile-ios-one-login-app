// TODO: DCMAW-10320 | Encode PoP Key correctly as JWK
struct ClientAssertionRequest: Encodable {
    let jwk: String
}
