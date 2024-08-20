import Network
@testable import OneLogin
import XCTest

 final class ServiceTests: XCTestCase {
    func testInitialize() throws {
        let url = URL(string: "https://example.com")!
        Service.initialize(baseURL: url)
        XCTAssertEqual(Service.baseURL, url)
    }
 }
