import MobilePlatformServices
@testable import Networking

final class MockHelloWorldService: HelloWorldProvider {
    var didRequestHelloWorld: Bool = false
    var helloWorldError: Error?

    var didRequestHelloWorldWithWrongScope = false
    var didRequestHelloWorldAtWrongEndpoint = false

    func requestHelloWorld() async throws -> String {
        didRequestHelloWorld = true

        if let helloWorldError {
            throw helloWorldError
        }

        return "Success: testData"
    }
    
    func requestHelloWorldWrongScope() async throws {
        didRequestHelloWorldWithWrongScope = true
        
        if let helloWorldError {
            throw helloWorldError
        }

        throw ServerError(endpoint: "hello-world", errorCode: 404)
    }
    
    func requestHelloWorldWrongEndpoint() async throws {
        didRequestHelloWorldAtWrongEndpoint = true

        if let helloWorldError {
            throw helloWorldError
        }

        throw MockNetworkClientError.genericError
    }
}
