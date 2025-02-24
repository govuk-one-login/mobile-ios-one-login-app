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
    func testFetchToken_throwsErrorForMissingToken() async throws {
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

    func testFetchToken_makesTokenExchangeRequest() async throws {
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
            URLQueryItem(name: "grant_type", value: "urn:ietf:params:oauth:grant-type:token-exchange"),
            URLQueryItem(name: "scope", value: scope),
            URLQueryItem(name: "subject_token", value: subjectToken),
            URLQueryItem(name: "subject_token_type", value: "urn:ietf:params:oauth:token-type:access_token")
        ])
    }

    func testFetchToken_returnsExpectedToken() async throws {
        // GIVEN I am connected to the internet
        let exp = expectation(description: "Received a network request")
        exp.assertForOverFulfill = true

        let expectedToken = UUID().uuidString
        MockURLProtocol.handler = {
            let response = """
            {
                "accessToken": "\(expectedToken)",
                "tokenType": "jwt",
                "expiresIn": 180
            }
            """
            return (Data(response.utf8), HTTPURLResponse(statusCode: 200))
        }

        // AND I have an valid access token
        let subjectToken = UUID().uuidString
        sut.update(subjectToken: subjectToken)

        // WHEN the a scoped token is requested
        Task {
            do {
                let token = try await sut
                    .fetchToken(withScope: "sts.hello-world.read")

                // THEN the expected token is returned
                XCTAssertEqual(token, expectedToken)
            } catch {
                XCTFail("Expected success but error (\(error)) occurred")
            }

            exp.fulfill()
        }

        await fulfillment(of: [exp], timeout: 5)
    }

    func testFetchToken_sendsExpiredSessionNotification() async {
        // GIVEN I am connected to the internet
        let exp = XCTNSNotificationExpectation(
            name: .sessionExpired,
            object: nil,
            notificationCenter: NotificationCenter.default
        )
        exp.assertForOverFulfill = true

        MockURLProtocol.handler = {
            (Data(), HTTPURLResponse(statusCode: 400))
        }

        // WHEN my access token has expired
        Task {
            sut.update(subjectToken: "abc")
            _ = try await sut.fetchToken(withScope: "sts.hello-world.read")
        }

        // THEN an XCTNSNotificationExpectation is sent
        await fulfillment(of: [exp], timeout: 5)
    }
}
