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
        sut = JWTVerifier(token: MockJWKSResponse.idToken, networkClient: networkClient)
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
        
        let userCredential = try await sut.verifyCredential()
        
        XCTAssertEqual(userCredential?.email, "abc@example.com")
    }

    func test_verifyInvalidJWT() async throws {
        let exp = expectation(description: "Failed on invalid JWT Format")
        MockURLProtocol.handler = {
            (MockJWKSResponse.jwksJson, HTTPURLResponse(statusCode: 200))
        }
        sut = .init(token: MockJWKSResponse.malformedToken, networkClient: networkClient)
        do {
            _ = try await sut.verifyCredential()
        } catch JWTVerifier.JWTVerifierError.invalidJWTFormat {
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
        sut = .init(token: "This is a fake token", networkClient: networkClient)
        do {
            _ = try await sut.verifyCredential()
        } catch JWTVerifier.JWTVerifierError.invalidJWTFormat {
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
        
        do {
            _ = try await sut.verifyCredential()
        } catch JWTVerifier.JWTVerifierError.invalidKID {
            exp.fulfill()
        } catch {
            XCTFail("Failed on another error: \(error)")
        }
        
        await fulfillment(of: [exp], timeout: 3)
    }
    
    func test_unableToFetchJWKs() async throws {
        MockURLProtocol.handler = {
            (.init(), HTTPURLResponse(statusCode: 200))
        }
        
        do {
            let credential = try await sut.verifyCredential()
            XCTFail("Expected failure: no JWK data")
        } catch {
            // Expect this
        }
    }
}
