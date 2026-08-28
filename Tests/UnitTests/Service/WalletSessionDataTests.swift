@testable import OneLogin
import Testing
import WalletStore

struct WalletSessionDataTests {
    
    @Test func assertWalletUnsafeStateThrown() async throws {
        func deleteThrowsWalletUnsafeState() async throws(WalletStoreError) -> [WalletStoreError] {
            throw WalletStoreError(.walletUnsafeState)
        }
        
        let mockWalletSDK = MockWalletSDKWrapper(deleteAsFunction: deleteThrowsWalletUnsafeState)
        
        let walletSessionData = WalletSessionData(walletSDK: mockWalletSDK)
        
        let error = await #expect(throws: WalletStoreError.self) {
            try await walletSessionData.clearSessionData()
        }
        
        #expect(error?.kind == .walletUnsafeState)
    }
    
    @Test func assertErrorsNotThrown() async throws {
        func deleteReturnsErrors() async throws(WalletStoreError) -> [WalletStoreError] {
            let anyOtherThanWalletUnsafeStateErrors = [
                WalletStoreError(.updateDocumentExpiryDate),
                WalletStoreError(.updateValid)
            ]
            
            return anyOtherThanWalletUnsafeStateErrors
        }
        
        let mockWalletSDK = MockWalletSDKWrapper(deleteAsFunction: deleteReturnsErrors)
        
        let walletSessionData = WalletSessionData(walletSDK: mockWalletSDK)
        
        await #expect(throws: Never.self) {
            try await walletSessionData.clearSessionData()
        }
    }
    
    @Test func assertWarningsStream() async throws {
        let first: WalletStoreError = WalletStoreError(.updateDocumentExpiryDate)
        let second: WalletStoreError = WalletStoreError(.updateValid)
        
        func deleteReturnsErrors() async throws(WalletStoreError) -> [WalletStoreError] {
            let anyOtherThanWalletUnsafeStateErrors = [
                first,
                second
            ]
            
            return anyOtherThanWalletUnsafeStateErrors
        }
        
        let mockWalletSDK = MockWalletSDKWrapper(deleteAsFunction: deleteReturnsErrors)
        
        let walletSessionData = WalletSessionData(walletSDK: mockWalletSDK)
        var warningsStream = await walletSessionData.streamClearSessionDataWarnings.makeAsyncIterator()
        
        try await walletSessionData.clearSessionData()
        
        #expect(await warningsStream.next() == first)
        #expect(await warningsStream.next() == second)
    }
    
    @Test func assertNoWarningsStream() async throws {
        func deleteNoErrors() async throws(WalletStoreError) -> [WalletStoreError] {
            return []
        }
        
        let mockWalletSDK = MockWalletSDKWrapper(deleteAsFunction: deleteNoErrors)
        
        let walletSessionData = WalletSessionData(walletSDK: mockWalletSDK)
        var warningsStream = await walletSessionData.streamClearSessionDataWarnings.makeAsyncIterator()
        
        try await walletSessionData.clearSessionData()
        
        #expect(await warningsStream.next() == nil)
    }
    
    @Test func assertWarningsStreamOnSecondSessionData() async throws {
        let error: WalletStoreError = WalletStoreError(.updateValid)
        
        var called = false
        func deleteReturnsErrors() async throws(WalletStoreError) -> [WalletStoreError] {
            defer {
                called = true
            }
            
            if !called {
                return []
            } else {
                return [error]
            }
        }
        
        let mockWalletSDK = MockWalletSDKWrapper(deleteAsFunction: deleteReturnsErrors)
        
        let walletSessionData = WalletSessionData(walletSDK: mockWalletSDK)
        
        try await walletSessionData.clearSessionData()
        
        var warningsStream = await walletSessionData.streamClearSessionDataWarnings.makeAsyncIterator()
        try await walletSessionData.clearSessionData()
    
        #expect(await warningsStream.next() == error)
    }
    
    @Test func assertWarningsStreamPerClearSessionData() async throws {
        let one: WalletStoreError = WalletStoreError(.updateDocumentExpiryDate)
        let another: WalletStoreError = WalletStoreError(.updateValid)

        var called = false
        func deleteReturnsErrors() async throws(WalletStoreError) -> [WalletStoreError] {
            defer {
                called = true
            }
            
            if !called {
                return [one]
            } else {
                return [another]
            }
        }
        
        let mockWalletSDK = MockWalletSDKWrapper(deleteAsFunction: deleteReturnsErrors)
        
        let walletSessionData = WalletSessionData(walletSDK: mockWalletSDK)
        
        var oneWarningsStream = await walletSessionData.streamClearSessionDataWarnings.makeAsyncIterator()
        try await walletSessionData.clearSessionData()

        #expect(await oneWarningsStream.next() == one)
        #expect(await oneWarningsStream.next() == nil)

        var anotherWarningsStream = await walletSessionData.streamClearSessionDataWarnings.makeAsyncIterator()
        try await walletSessionData.clearSessionData()
    
        #expect(await anotherWarningsStream.next() == another)
        #expect(await anotherWarningsStream.next() == nil)
    }
    
    @Test func assertWarningsStreamNotMissedAfterWalletSessionDataGoesAway() async throws {
        let error: WalletStoreError = WalletStoreError(.updateDocumentExpiryDate)

        func deleteReturnsErrors() async throws(WalletStoreError) -> [WalletStoreError] {
            let anyOtherThanWalletUnsafeStateErrors = [
                error
            ]
            
            return anyOtherThanWalletUnsafeStateErrors
        }
        
        let mockWalletSDK = MockWalletSDKWrapper(deleteAsFunction: deleteReturnsErrors)
        
        var walletSessionData: Optional = WalletSessionData(walletSDK: mockWalletSDK)
        var warningsStream = await walletSessionData?.streamClearSessionDataWarnings.makeAsyncIterator()
        
        try await walletSessionData?.clearSessionData()
        
        walletSessionData = nil
        
        #expect(await warningsStream?.next() == error)
    }
    
    @Test func assertWarningsStreamAfterClearSessionDataCalledDeinit() async throws {
        let error: WalletStoreError = WalletStoreError(.updateDocumentExpiryDate)

        func deleteReturnsErrors() async throws(WalletStoreError) -> [WalletStoreError] {
            let anyOtherThanWalletUnsafeStateErrors = [
                error
            ]
            
            return anyOtherThanWalletUnsafeStateErrors
        }
        
        let mockWalletSDK = MockWalletSDKWrapper(deleteAsFunction: deleteReturnsErrors)
        
        var walletSessionData: Optional = WalletSessionData(walletSDK: mockWalletSDK)
        
        try await walletSessionData?.clearSessionData()
        
        var warningsStream = await walletSessionData?.streamClearSessionDataWarnings.makeAsyncIterator()

        walletSessionData = nil
        
        #expect(await warningsStream?.next() == nil)
    }
    
    @Test func assertWarningsStreamTaskCancellation() async throws {
        let error: WalletStoreError = WalletStoreError(.updateDocumentExpiryDate)

        func deleteReturnsErrors() async throws(WalletStoreError) -> [WalletStoreError] {
            let anyOtherThanWalletUnsafeStateErrors = [
                error
            ]
            
            return anyOtherThanWalletUnsafeStateErrors
        }
        
        let mockWalletSDK = MockWalletSDKWrapper(deleteAsFunction: deleteReturnsErrors)
        
        let walletSessionData = WalletSessionData(walletSDK: mockWalletSDK)
        
        let streamClearSessionDataWarnings = await walletSessionData.streamClearSessionDataWarnings
        try await walletSessionData.clearSessionData()
        
        let observeWarnings = Task {
            var warningsStream = streamClearSessionDataWarnings.makeAsyncIterator()
            return await warningsStream.next()
        }
        
        observeWarnings.cancel()
        
        #expect(await observeWarnings.value == error)
    }
    
    @Test func assertWarningsStreamTaskCancellationOnStreamWithoutClearSessionDataCall() async throws {
        let error: WalletStoreError = WalletStoreError(.updateDocumentExpiryDate)

        func deleteReturnsErrors() async throws(WalletStoreError) -> [WalletStoreError] {
            let anyOtherThanWalletUnsafeStateErrors = [
                error
            ]
            
            return anyOtherThanWalletUnsafeStateErrors
        }
        
        let mockWalletSDK = MockWalletSDKWrapper(deleteAsFunction: deleteReturnsErrors)
        
        let walletSessionData = WalletSessionData(walletSDK: mockWalletSDK)
        
        try await walletSessionData.clearSessionData()
        let streamClearSessionDataWarnings = await walletSessionData.streamClearSessionDataWarnings
        
        let observeWarnings = Task {
            var warningsStream = streamClearSessionDataWarnings.makeAsyncIterator()
            return await warningsStream.next()
        }
        
        observeWarnings.cancel()
        
        #expect(await observeWarnings.value == nil)
    }
    
    @Test func assertWarningsStreamUsingStructuredTask() async throws {
        let error: WalletStoreError = WalletStoreError(.updateDocumentExpiryDate)

        func deleteReturnsErrors() async throws(WalletStoreError) -> [WalletStoreError] {
            let anyOtherThanWalletUnsafeStateErrors = [
                error
            ]
            
            return anyOtherThanWalletUnsafeStateErrors
        }
        
        let mockWalletSDK = MockWalletSDKWrapper(deleteAsFunction: deleteReturnsErrors)
        
        let walletSessionData = WalletSessionData(walletSDK: mockWalletSDK)
        
        let streamClearSessionDataWarnings = await walletSessionData.streamClearSessionDataWarnings
        try await walletSessionData.clearSessionData()
        
        async let observeWarnings = {
            var warningsStream = streamClearSessionDataWarnings.makeAsyncIterator()
            return await warningsStream.next()
        }()
        
        #expect(await observeWarnings == error)
    }
}
