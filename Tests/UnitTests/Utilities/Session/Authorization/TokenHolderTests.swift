import MockNetworking
@testable import Networking
@testable import OneLogin
import XCTest

final class TokenHolderTests: XCTestCase {
    var sut: TokenHolder!

    override func setUp() {
        super.setUp()

        MockURLProtocol.clear()
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]

        let client = NetworkClient(configuration: configuration)

        sut = TokenHolder(client: client)
    }

    override func tearDown() {
        MockURLProtocol.clear()
        sut = nil
        super.tearDown()
    }
}

extension TokenHolderTests {
    func test_fetchToken_throwsErrorForMissingToken() async throws {
        // GIVEN I am connected to the internet
        let exp = expectation(description: "Received a network request")
        exp.assertForOverFulfill = true

        // AND I have no valid access token
        // WHEN the a scoped token is requested
        Task {
            do {
                _ = try await sut
                    .fetchToken(withScope: "sts.hello-world.read")
                XCTFail("Expected `bearerNotPresent` error to be thrown")
            } catch TokenError.bearerNotPresent {
                // expected path
            } catch {
                XCTFail("Expected `bearerNotPresent` error to be thrown")
            }
            exp.fulfill()
        }

        // THEN an error is thrown
        await fulfillment(of: [exp], timeout: 5)
    }

    func test_fetchToken_makesTokenExchangeRequest() async throws {
        // GIVEN I am connected to the internet
        let exp = expectation(description: "Received a network request")
        exp.assertForOverFulfill = true

        MockURLProtocol.handler = {
            exp.fulfill()
            return (Data("testData".utf8), HTTPURLResponse(statusCode: 200))
        }

        // AND I have an valid access token
        let subjectToken = UUID().uuidString
        sut.update(subjectToken: subjectToken)

        // WHEN the a scoped token is requested
        let scope = UUID().uuidString
        Task {
            try await sut.fetchToken(withScope: scope)
        }

        // THEN a request is made to exchange the access token
        await fulfillment(of: [exp], timeout: 5)

        let request = try XCTUnwrap(MockURLProtocol.requests.first)
        XCTAssertEqual(request.url?.absoluteString,
                       "https://token.build.account.gov.uk/token")
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"),
                       "application/x-www-form-urlencoded")

        let data = try XCTUnwrap(request.httpBodyData())
        let body = String(data: data, encoding: .utf8)
        
        var components = URLComponents()
        components.query = body

        XCTAssertEqual(components.queryItems, [
            URLQueryItem(name: "subject_token_type", value: "urn:ietf:params:oauth:token-type:access_token"),
            URLQueryItem(name: "grant_type", value: "urn:ietf:params:oauth:grant-type:token-exchange"),
            URLQueryItem(name: "subject_token", value: subjectToken),
            URLQueryItem(name: "scope", value: scope)
        ])
    }

    func test_fetchToken_returnsExpectedToken() async throws {
        // GIVEN I am connected to the internet
        let expectedToken = UUID().uuidString
        MockURLProtocol.handler = {
            let response = """
            {
                "access_token": "\(expectedToken)",
                "token_type": "token",
                "expires_in": 180
            }
            """
            return (Data(response.utf8), HTTPURLResponse(statusCode: 200))
        }
        
        // AND I have an valid access token
        sut.update(subjectToken: expectedToken)
        
        // WHEN the a scoped token is requested
        do {
            let token = try await sut
                .fetchToken(withScope: "sts.hello-world.read")
            
            // THEN the expected token is returned
            XCTAssertEqual(token, expectedToken)
        } catch {
            XCTFail("Expected success but error (\(error)) occurred")
        }
    }
}
