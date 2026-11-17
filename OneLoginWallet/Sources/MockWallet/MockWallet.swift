import WalletProtocol

public class MockWallet: WalletServiceProtocol {
    public typealias DeleteAsFunction = () async throws -> [Error]

    public var deleteAsFunction: DeleteAsFunction

    public var isEmpty: Bool = true

    public init(deleteAsFunction: @escaping DeleteAsFunction = { [] }) {
        self.deleteAsFunction = deleteAsFunction
    }

    public func delete() async throws -> [Error] {
        try await self.deleteAsFunction()
    }

    public func isEmpty() async -> Bool {
        return isEmpty
    }
}
