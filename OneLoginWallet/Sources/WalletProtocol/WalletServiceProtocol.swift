public protocol WalletServiceProtocol {
    func delete() async throws -> [Error]
    func isEmpty() async -> Bool
}
