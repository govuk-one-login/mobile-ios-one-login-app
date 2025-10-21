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
        
        networkClient = NetworkClient(configuration: configuration)
        networkClient.authorizationProvider = MockAuthenticationProvider()
        sut = JWTVerifier(networkClient: networkClient)
    }

    override func tearDown() {
        sut = nil
        networkClient = nil
        MockURLProtocol.clear()
        
        super.tearDown()
    }
    
    func test_verifyValidIDToken() async throws {
        MockURLProtocol.handler = {
            (MockJWKs.jwksJson, HTTPURLResponse(statusCode: 200))
        }
        
        let token = MockJWTs.genericToken
        let payload: IdTokenPayload = try await sut.verifyToken(token)
        
        XCTAssertEqual(payload.email, "mock@email.com")
        XCTAssertEqual(payload.persistentId, "1d003342-efd1-4ded-9c11-32e0f15acae6")
    }
    
    func test_verifyValidRefreshToken() async throws {
        MockURLProtocol.handler = {
            (MockJWKs.jwksJson, HTTPURLResponse(statusCode: 200))
        }
        
        let payload: RefreshTokenPayload = try await sut.verifyToken(MockJWTs.genericToken)
        
        XCTAssertEqual(payload.exp, ExpirationClaim(value: Date(timeIntervalSince1970: 1719397758)))
    }

    func test_verifyInvalidJWT() async throws {
        let exp = expectation(description: "Failed on invalid JWT Format")
        
        MockURLProtocol.handler = {
            (MockJWKs.jwksJson, HTTPURLResponse(statusCode: 200))
        }
        
        do {
            let _: IdTokenPayload = try await sut.verifyToken(MockJWTs.malformedToken)
        } catch JWTVerifierError.invalidJWTFormat {
            exp.fulfill()
        } catch {
            XCTFail("Failed on another error: \(error)")
        }
        
        await fulfillment(of: [exp], timeout: 3)
    }
    
    func test_verifyInvalidSignature() async throws {
        let exp = expectation(description: "Failed on invalid JWT Format")
        
        MockURLProtocol.handler = {
            (MockJWKs.jwksJson, HTTPURLResponse(statusCode: 200))
        }
                
        do {
            let _: IdTokenPayload = try await sut.verifyToken("This is a fake token")
        } catch JWTVerifierError.invalidJWTFormat {
            exp.fulfill()
        } catch {
            XCTFail("Failed on another error: \(error)")
        }
        
        await fulfillment(of: [exp], timeout: 3)

    }
    
    func test_verifyNoMatchingKIDs() async throws {
        let exp = expectation(description: "Failed on no matching kid")
        
        MockURLProtocol.handler = {
            (MockJWKs.jwksJsonNonMatchingKIDs, HTTPURLResponse(statusCode: 200))
        }
        
        do {
            let _: IdTokenPayload = try await sut.verifyToken(MockJWTs.genericToken)
        } catch JWTVerifierError.invalidKID {
            exp.fulfill()
        } catch {
            XCTFail("Failed on another error: \(error)")
        }
        
        await fulfillment(of: [exp], timeout: 3)
    }
    
    func test_fetchJWKs_networkError() async throws {
        MockURLProtocol.handler = {
            (MockJWKs.jwksJson, HTTPURLResponse(statusCode: 400))
        }
        
        do {
            let _: IdTokenPayload = try await sut.verifyToken(MockJWTs.genericToken)
            XCTFail("Expected failure: network error")
        } catch {
            // Expect this
        }
    }
    
    func test_extractToken() throws {
        let payload: IdTokenPayload = try sut.extractPayload(MockJWTs.genericToken)
        
        XCTAssertEqual(payload.email, "mock@email.com")
        XCTAssertEqual(payload.persistentId, "1d003342-efd1-4ded-9c11-32e0f15acae6")
    }
    
    func test_extractTokenFailure() throws {
        do {
            let _: IdTokenPayload = try sut.extractPayload(MockJWTs.malformedToken)
            XCTFail("Expected failure: extraction error")
        } catch {
            // Expect this
        }
    }
}
