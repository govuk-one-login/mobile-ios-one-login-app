import MockNetworking
@testable import Networking
@testable import OneLogin
import XCTest

final class TokenHolderTests: XCTestCase {
    var sut: TokenHolder!

    override func setUp() {
        super.setUp()

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
    func testFetchToken_throwsErrorForMissingToken() throws {
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
        wait(for: [exp], timeout: 5)
    }

    func testFetchToken_makesTokenExchangeRequest() throws {
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
        wait(for: [exp], timeout: 5)

        let request = try XCTUnwrap(MockURLProtocol.requests.first)
        XCTAssertEqual(request.url?.absoluteString,
                       "https://token.build.account.gov.uk/token")
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"),
                       "application/x-www-form-urlencoded")

        // TODO: check subjectToken & scope
    }

    func testFetchToken_returnsExpectedToken() throws {
        // GIVEN I am connected to the internet
        let exp = expectation(description: "Received a network request")
        exp.assertForOverFulfill = true

        let expectedToken = UUID().uuidString
        MockURLProtocol.handler = {
            exp.fulfill()

            let response = """
            {
                "accessToken": "\(expectedToken)"
                "tokenType": "jwt",
                "expiresIn": 180
            }
            """
            return (Data("testData".utf8), HTTPURLResponse(statusCode: 200))
        }

        // AND I have an valid access token
        let subjectToken = UUID().uuidString
        sut.update(subjectToken: subjectToken)

        // WHEN the a scoped token is requested
        Task {
            let token = try await sut
                .fetchToken(withScope: "sts.hello-world.read")
            XCTAssertEqual(token, expectedToken)
            exp.fulfill()
        }

        wait(for: [exp], timeout: 5)
    }
}
