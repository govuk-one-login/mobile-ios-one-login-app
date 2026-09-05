import Logging
@testable import OneLogin

final class MockAnalyticsPreferenceStore: AnalyticsPreferenceStore, SessionBoundData {
    private var subscribers = [AsyncStream<Bool>.Continuation]()
    var hasAcceptedAnalytics: Bool?
    
    func stream() -> AsyncStream<Bool> {
        AsyncStream { element in
            subscribers.append(element)
        }
    }
    
    func clearSessionData() async throws {
        hasAcceptedAnalytics = false
    }
}
