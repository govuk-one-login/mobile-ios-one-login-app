@testable import LocalAuthenticationWrapper

final class MockLocalAuthPromptRecorder: LocalAuthPromptRecorder {
    var previouslyPrompted: Bool = false
    
    func recordPrompt() {
        previouslyPrompted = true
    }
}
