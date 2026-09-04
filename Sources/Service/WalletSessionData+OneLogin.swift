import Wallet
import WalletStore

/// Use to clear session data related to Wallet.
///
/// - SeeAlso: ``clearSessionData()`` for how to clear the session data.
/// - SeeAlso: ``streamClearSessionDataWarnings`` on how to best consume a stream of warnings.
actor WalletSessionData: SessionBoundData {
    
    /// Use to stream warnings emitted by each call to ``clearSessionData()``.
    ///
    /// To receive the warnings emitted by a call to ``clearSessionData()``, obtain the warning stream first
    /// followed by a call to ``clearSessionData()``.
    ///
    /// There are two recommended ways to consume the stream, in order of preference:
    /// 1. As a structured task, using `async let`.
    /// 2. As a `Task` scoped to observing the warnings.
    ///
    /// For example, using a structured task.
    ///
    /// ```
    /// func clearSessionData(
    ///     walletSessionData: WalletSessionData
    /// ) async throws {
    ///     let warnings = await walletSessionData.streamClearSessionDataWarnings
    ///
    ///     async let logWarnings: Void = {
    ///         for await warning in warnings {
    ///             analyticsService.logCrash(warning)
    ///         }
    ///     }()
    ///
    ///     try await walletSessionData.clearSessionData()
    ///     await logWarnings
    /// }
    /// ```
    ///
    /// Alternatively, using a `Task`.
    /// You should ensure that the task is cancelled irrespective of how ``clearSessionData`` completes;
    /// either succesfully or by throwing an error.
    ///
    /// ```
    /// func clearSessionData(
    ///     walletSessionData: WalletSessionData
    /// ) async throws {
    ///     let warnings = await walletSessionData.streamClearSessionDataWarnings
    ///
    ///     let logWarnings = Task {
    ///         for await warning in warnings {
    ///             analyticsService.logCrash(warning)
    ///         }
    ///     }
    ///
    ///     defer {
    ///         logWarnings.cancel()
    ///     }
    ///
    ///     try await walletSessionData.clearSessionData()
    ///     await logWarnings.value
    /// }
    /// ```
    ///
    /// You **must** wait for ``clearSessionData()`` to complete before obtaining another stream;
    /// overlapping calls are not supported and may result in warnings being lost.
    ///
    /// - SeeAlso: ``clearSessionData()`` for how warnings are produced.
    ///
    /// - Note: If a ``WalletSessionData`` instance is unexpectedly retained, a consumer waiting
    /// on a stream will remain suspended in the case of either omitting a call to ``clearSessionData()``
    /// or the observation task is not cancelled.
    private(set) var streamClearSessionDataWarnings: AsyncStream<WalletStoreError>
    private var clearSessionDataWarnings: AsyncStream<WalletStoreError>.Continuation

    private let walletSDK: WalletServiceProtocol
    
    public init(walletSDK: WalletServiceProtocol = WalletSDKWrapper.instance) {
        self.walletSDK = walletSDK
        (streamClearSessionDataWarnings, clearSessionDataWarnings) = AsyncStream<WalletStoreError>.makeStream()
    }
    
    deinit {
        clearSessionDataWarnings.finish()
    }
    
    /// Clears session data related to Wallet.
    ///
    /// Optionally, you can receive "warnings" via the ``streamClearSessionDataWarnings`` stream.
    /// "Warnings" conform to Error type that are NOT thrown thus not available to `catch`.
    ///
    /// Should you wish to observe any warnings when attempting to clear session data, make sure you subscribe to
    /// the ``streamClearSessionDataWarnings``  before making the call to ``clearSessionData()``
    ///
    /// e.g.
    ///
    /// ```
    /// var oneWarningsStream = walletSessionData.streamClearSessionDataWarnings.makeAsyncIterator()
    /// try await walletSessionData.clearSessionData()
    ///
    /// await oneWarningsStream.next() // to receive warnings from **one** call to clearSessionData
    ///
    /// var anotherWarningsStream = walletSessionData.streamClearSessionDataWarnings.makeAsyncIterator()
    /// try await walletSessionData.clearSessionData()
    ///
    /// await anotherWarningsStream.next() // to receive warnings from **another** call to clearSessionData
    /// ```
    ///
    /// The ``streamClearSessionDataWarnings`` stream, produces warnings by making a call to  ``clearSessionData()``.
    /// Once the function returns, the stream closes. Any warnings already emitted by the
    /// last call to ``clearSessionData()`` remain available until they are consumed.
    ///
    /// - throws: all errors thrown by ``WalletSDK/delete()`` that are considered "critical".
    /// - SeeAlso: ``WalletSDKWrapper/delete()``
    /// - Remark: You should not make calls to `clearSessionData()` that overlap. This is a misuse of the API and
    ///     may lead to missing and/or unexpected warnings.
    /// - Note: For any errors that are not "critical" the ``WalletSDK`` classifies them as
    /// "warnings" and are intented to be "informatonal" only (e.g. loggged for observability)
    func clearSessionData() async throws {
        let continuation = clearSessionDataWarnings
        
        defer {
            continuation.finish()
            (streamClearSessionDataWarnings, clearSessionDataWarnings) = AsyncStream<WalletStoreError>.makeStream()
        }
        
        for error in try await walletSDK.delete() {
            continuation.yield(error)
        }
    }
}

protocol WalletServiceProtocol {
    func delete() async throws(WalletStoreError) -> [WalletStoreError]
    func isEmpty() async -> Bool
}

struct WalletSDKWrapper: WalletServiceProtocol {
    
    static let instance = WalletSDKWrapper()
    
    /// Use ``instance`` to obtain a reference.
    private init() {
        // the `WalletSDKWrapper` is meant to represent an instance of the WalletSDK
        // when using its static function. Thus, using a `init` is moot.
    }
    
    func delete() async throws(WalletStoreError) -> [WalletStoreError] {
        try await WalletSDK.delete()
    }
    
    func isEmpty() async -> Bool {
        return await WalletSDK.isEmpty()
    }
}
