import AppIntegrity
import Dispatch

/// Use this type to automatically retry calls to `AppIntegrityProvider/integrityAssertions` every time an error is thrown.
///
/// e.g. the following code will make two (2) attempts at fetching the integrity assertions before giving up and throwing an error.
/// ```
///     let service = OneLoginAppIntegrityService(integrityService: integrityService)
///     service.integrityAssertions(attempts: 2)
/// ```
///
/// After that point the instance to `OneLoginAppIntegrityService` should be discarded.
/// Should you wish to make another number of attempts, you **must** create a new `OneLoginAppIntegrityService` instance.
///
/// - seealso: ``integrityAssertions(attempts:)`` on making an attempt at fetching the integrity assertions
actor OneLoginAppIntegrityService {
    private(set) var errorRetries = 0
    private let integrityService: AppIntegrityProvider
    
    init(integrityService: AppIntegrityProvider) {
        self.integrityService = integrityService
    }
    
    /// Attempts to return integrity assertions by invoking  `AppIntegrityProvider/integrityAssertions` on the `AppIntegrityProvider` used to consturct this instance.
    ///
    /// On specific [1] errors, the method retries up to the maximum attempts, then re-throws the `AppIntegrityProvider/integrityAssertions` error.
    ///
    /// [1]: Only the following errors will be retried:
    /// - `FirebaseAppCheckError/network`
    /// - `ClientAssertionError/invalidToken`
    /// - `ClientAssertionError/serverError`
    /// - `ClientAssertionError/cantDecodeClientAssertion`
    ///
    /// The first attempt is performed now; each follow-up attempt will incure an aditional 100ms delay per attempt over time.
    ///     e.g.
    ///     - attempt 1  → now
    ///     - attempt 2  → 100ms
    ///     - attempt 3  → 200ms
    ///     - attempt 4  → 300ms
    ///
    /// - parameter attempts: the number of attempts before giving up; **default** is 3.
    /// - returns the integrity assertions as returned by `AppIntegrityProvider/integrityAssertions`
    /// - throws the error as thrown by `AppIntegrityProvider/integrityAssertions` on the **last**  attempt.
    /// - remark: this function is not deisnged to be called in parallel, in which case its behaviour is undefined.
    /// No strong guarantees are provided when making concurrent calls to this function, e.g. 2 parallel calls may both lead to an attempt now.
    public func integrityAssertions(
        attempts maxAttempts: Int = 3
    ) async throws -> [String: String] {
        return try await self.attempt(max: maxAttempts)
    }

    private func attempt(
        _ retry: Int = 0,
        max maxAttempts: Int
    ) async throws -> [String: String] {
        do {
            return try await self.integrityAssertions(after: .milliseconds(100 * retry))
        } catch let error as FirebaseAppCheckError {
            switch error.kind {
            case .network:
                self.errorRetries = retry + 1
                if self.errorRetries >= maxAttempts {
                    throw error
                }
                return try await self.attempt(self.errorRetries, max: maxAttempts)
            case .unknown, .invalidConfiguration, .keychainAccess, .notSupported, .generic:
                throw error
            }
        } catch let error as ClientAssertionError {
            switch error.kind {
            case .invalidToken, .serverError, .cantDecodeClientAssertion:
                self.errorRetries = retry + 1
                if self.errorRetries >= maxAttempts {
                    throw error
                }
                return try await self.attempt(self.errorRetries, max: maxAttempts)
            case .invalidPublicKey:
                throw error
            }
        }
    }
    
    private func integrityAssertions(
        after interval: DispatchTimeInterval
    ) async throws -> [String: String] {
        try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global().asyncAfter(deadline: .now() + interval) {
                Task {
                    do {
                        let result = try await self.integrityService.integrityAssertions
                        continuation.resume(returning: result)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }
}
