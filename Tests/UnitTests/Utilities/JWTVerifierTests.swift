import JWTKit
import MockNetworking
@testable import Networking
@testable import OneLogin
import XCTest

final class JWTVerifierTests: XCTestCase {

    var sut: JWTVerifier!
    var networkClient: NetworkClient!
    
    override func setUp() {
        super.setUp()
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        
        networkClient = NetworkClient()

        sut = JWTVerifier(token: MockJWKSResponse.idToken, networkClient: networkClient)
    }

    override func tearDown() {
        sut = nil
        networkClient = nil
        super.tearDown()
    }
    
    func test_verify() async throws {
        MockURLProtocol.handler = {
            (MockJWKSResponse.jwksJson, HTTPURLResponse(statusCode: 200))
        }
        
        let jwksInfo = try await sut.fetchJWK()
        let unwrappedJwk = try XCTUnwrap(try jwksInfo?.signingJWK)
        XCTAssertEqual(unwrappedJwk.algorithm, JWK.Algorithm.es256)
        let keyVerifier = try ES256KeyVerifier(jsonWebKey: unwrappedJwk)

            let cred = try keyVerifier.verify(jwt: MockJWKSResponse.idToken)
        
    }
}
