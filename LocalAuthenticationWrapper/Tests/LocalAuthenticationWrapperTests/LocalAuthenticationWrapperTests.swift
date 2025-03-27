@testable import LocalAuthenticationWrapper
import Testing

struct LocalAuthenticationWrapperTests {
    private var mockLocalAuthContext: LocalAuthContext!
    private var mockAuthPromptStore: LocalAuthPromptRecorder!
    private var mockLocalAuthStrings: LocalAuthPromptStrings!
    private var sut: LocalAuthenticationWrapper!
    
    init() {
        sut = LocalAuthenticationWrapper(
            localAuthContext: mockLocalAuthContext,
            localAuthPromptStore: mockAuthPromptStore,
            localAuthStrings: mockLocalAuthStrings
        )
    }
    
    @Test
    func example() {
    }
}
