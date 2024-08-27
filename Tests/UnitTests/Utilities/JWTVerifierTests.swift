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
        sut = JWTVerifier(networkClient: networkClient)
    }

    override func tearDown() {
        sut = nil
        networkClient = nil
        super.tearDown()
    }
    
    func test_verifyValidCredential() async throws {
        MockURLProtocol.handler = {
            (MockJWKSResponse.jwksJson, HTTPURLResponse(statusCode: 200))
        }
        
        let token = MockJWKSResponse.idToken
        let payload = try await sut.verifyToken(token)
        
        XCTAssertEqual(payload.email, "mock@email.com")
        XCTAssertEqual(payload.persistentId, "1d003342-efd1-4ded-9c11-32e0f15acae6")
    }

    func test_verifyInvalidJWT() async throws {
        let exp = expectation(description: "Failed on invalid JWT Format")
        MockURLProtocol.handler = {
            (MockJWKSResponse.jwksJson, HTTPURLResponse(statusCode: 200))
        }
        sut = .init(networkClient: networkClient)
        do {
            _ = try await sut.verifyToken(MockJWKSResponse.malformedToken)
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
            (MockJWKSResponse.jwksJson, HTTPURLResponse(statusCode: 200))
        }
        sut = .init(networkClient: networkClient)
        let token = "This is a fake token"
        do {
            _ = try await sut.verifyToken(token)
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
            (MockJWKSResponse.jwksJsonNonMatchingKIDs, HTTPURLResponse(statusCode: 200))
        }
        let token = MockJWKSResponse.idToken
        do {
            _ = try await sut.verifyToken(token)
        } catch JWTVerifierError.invalidKID {
            exp.fulfill()
        } catch {
            XCTFail("Failed on another error: \(error)")
        }
        
        await fulfillment(of: [exp], timeout: 3)
    }
    
    func test_fetchJWKs_networkError() async throws {
        MockURLProtocol.handler = {
            (MockJWKSResponse.jwksJson, HTTPURLResponse(statusCode: 400))
        }
        let token = MockJWKSResponse.idToken
        do {
            _ = try await sut.verifyToken(token)
            XCTFail("Expected failure: network error")
        } catch {
            // Expect this
        }
    }
    
    func test_extractToken() throws {
        let token = MockJWKSResponse.idToken
        let payload = try sut.extractPayload(token)
        
        XCTAssertEqual(payload.email, "mock@email.com")
        XCTAssertEqual(payload.persistentId, "1d003342-efd1-4ded-9c11-32e0f15acae6")
    }
    
    func test_extractTokenFailure() throws {
        let token = MockJWKSResponse.malformedToken
        
        do {
            _ = try  sut.extractPayload(token)
            XCTFail("Expected failure: extraction error")
        } catch {
            // Expect this
        }
    }
}
