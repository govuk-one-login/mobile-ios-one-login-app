public protocol HelloWorldProvider {
    func requestHelloWorld() async throws -> String
    func requestHelloWorldWrongScope() async throws
    func requestHelloWorldWrongEndpoint() async throws
}
