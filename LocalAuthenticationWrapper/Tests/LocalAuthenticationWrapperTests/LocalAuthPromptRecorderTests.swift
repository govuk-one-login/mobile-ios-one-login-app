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
        UserDefaults.standard.removeObject(forKey: "localAuthPasscodePrompted")
    }
    
    @Test("Check previously prompted is not true by default")
    func notPreviouslyPrompted() {
        #expect(!sut.previouslyPrompted)
    }
    
    @Test("Check previously prompted is true if set")
    func previouslyPrompted() {
        sut.recordPrompt()
        #expect(sut.previouslyPrompted)
    }
}
