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
    func example() {
        #expect(!sut.previouslyPrompted)
    }
    
    @Test
    func example2() {
        sut.recordPrompt()
        #expect(sut.previouslyPrompted)
    }
}
