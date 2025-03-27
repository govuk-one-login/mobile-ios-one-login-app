import Foundation
@testable import LocalAuthenticationWrapper
import Testing

@Suite(.serialized)
class LocalAuthPromptRecorderTests {
    var sut: LocalAuthPromptRecorder!
    
    init() {
        sut = UserDefaults.standard
    }
    
    deinit {
        UserDefaults.standard.removeObject(forKey: "localAuthPrompted")
    }
    
    @Test
    func notPreviouslyPrompted() {
        #expect(!sut.previouslyPrompted)
    }
    
    @Test
    func previouslyPrompted() {
        sut.recordPrompt()
        #expect(sut.previouslyPrompted)
    }
}
