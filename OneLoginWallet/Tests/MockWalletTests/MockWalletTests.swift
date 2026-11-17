@testable import MockWallet
import Testing
import WalletStore

extension MockWallet {
    static func make(
        deleteAsFunction: @escaping DeleteAsFunction = { return [] }
    ) -> MockWallet {
        return MockWallet(
            deleteAsFunction: deleteAsFunction
        )
    }
}

struct MockWalletTests {
    @Test
    func creatingMock() {
        let sut: MockWallet = .make()
        #expect(sut.isEmpty)
    }
    
    @Test
    func mockWalletDelete() async throws {
        var didCallDelete = false
        
        let sut: MockWallet = .make(deleteAsFunction: {
            didCallDelete = true
            return []
        })
        
        _ = try await sut.delete()
        
        #expect(didCallDelete)
    }
}
