import GDSCommon
@testable import OneLogin
import Testing

@MainActor
struct ExternalButtonIconViewModelTests {
    @Test("Default values")
    func defaultValues() {
        let sut = ExternalButtonIconViewModel.external
        #expect(sut.iconName == "arrow.up.right")
        #expect(sut.symbolPosition == SymbolPosition.afterTitle)
    }
}
