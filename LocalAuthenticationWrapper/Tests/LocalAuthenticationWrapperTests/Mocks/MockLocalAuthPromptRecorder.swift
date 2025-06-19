@testable import LocalAuthenticationWrapper

final class MockLocalAuthPromptRecorder: LocalAuthPromptRecorder {
    var previouslyPrompted: Bool = false
    var previouslyPasscodePrompted: Bool = false
    
    func recordPrompt() {
        previouslyPrompted = true
    }
    
    func recordPasscodePrompt() {
        previouslyPasscodePrompted = true
    }
}
