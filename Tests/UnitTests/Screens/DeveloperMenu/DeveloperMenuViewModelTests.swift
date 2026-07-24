@testable import OneLogin
import Testing

@MainActor
struct DeveloperMenuViewModelTests {
    var sut: DeveloperMenuViewModel!
    
    init() {
        sut = DeveloperMenuViewModel()
    }
}

extension DeveloperMenuViewModelTests {
    @Test
    func test_screen_contents() throws {
        #expect(sut.rightBarButtonTitle?.stringKey == "app_cancelButton")
        #expect(sut.backButtonTitle == nil)
        #expect(sut.backButtonIsHidden)
        #expect(sut.didAppear == nil)
        #expect(sut.didDismiss == nil)
    }
}
