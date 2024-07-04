import Networking
import PactConsumerSwift
import XCTest

final class PactTests: XCTestCase {

    var mockService: MockService!
    var networkClient: NetworkClient?
    var request: URLRequest!
    var requestBody: MockRequestBody!
    var responseBody: MockResponseBody!

    override func setUp() {
        super.setUp()

        request = URLRequest(url: URL(string: "http://localhost:1234/pact-test")!)
        let requestBody = ["request": "mock_request"]
        let encoded = try? JSONEncoder().encode(requestBody)
        request.httpBody = encoded
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        mockService = MockService(provider: "Mobile:MobilePlatform:DummyProvider", consumer: "OneLogin App")
        networkClient = NetworkClient()
    }

    override func tearDown() {
        request = nil
        mockService = nil
        networkClient = nil
        request = nil
        requestBody = nil
        responseBody = nil
    }

    func testMockRequest() {
        mockService
            .uponReceiving("A Mock Request")
            .withRequest(method: .POST, path: "/pact-test", headers: ["Content-Type": "application/json"], body: ["request": "mock_request"])
            .willRespondWith(status: 200,
                             headers: ["Content-Type": "application/json"],
                             body: [ "response": "mock_response" ])

        mockService.run(timeout: 60) { (testComplete) in
            Task {
                let result = try await self.networkClient?.makeRequest(self.request)
                let resultDict = try JSONDecoder().decode([String: String].self, from: result!)
                XCTAssertEqual(resultDict["response"], "mock_response")
                testComplete()
            }
        }
    }
}
