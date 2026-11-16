@testable import MockWallet
import Testing

extension MockWalletSDKWrapper {
    static func make(
        deleteAsFunction: @escaping DeleteAsFunction = { return [] }
    ) -> MockWalletSDKWrapper {
        return MockWalletSDKWrapper(
            deleteAsFunction: deleteAsFunction
        )
    }
}

@Test
func creatingMock() {
    let sut: MockWalletSDKWrapper = .make()
    #expect(sut.isEmpty)
}
