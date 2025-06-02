import GDSCommon
@testable import OneLogin
import XCTest

@MainActor
final class PurposeTileViewModelTests: XCTestCase {
    var mockAnalyticsService: MockAnalyticsService!
    var sut: PurposeTileViewModel!
        
    override func setUp() {
        super.setUp()
        
        sut = PurposeTileViewModel()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
}

extension PurposeTileViewModelTests {
    func test_view_contents() {
        XCTAssertEqual(sut.title.value, "How to prove your identity")
        // swiftlint:disable:next line_length
        XCTAssertEqual(sut.body.value, "If you need to prove your identity with GOV.UK One Login to access a service, you'll be asked to open this app. It works by matching your face to your photo ID.")
        XCTAssertFalse(sut.showSeparatorLine)
        XCTAssertEqual(sut.backgroundColour, .secondarySystemGroupedBackground)
    }
}
