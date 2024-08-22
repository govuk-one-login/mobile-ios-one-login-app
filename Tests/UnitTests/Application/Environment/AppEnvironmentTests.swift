import Foundation
@testable import OneLogin
import XCTest

final class AppEnvironmentTests: XCTestCase {
    func test_defaultEnvironment_addingReleaseFlags() {
        // GIVEN no release flags from AppInfo end point
        // pass in release flags to enviroment
        
        let releaseFlag = AppEnvironment.updateReleaseFlags(["test1": true, "test2": false])
        
        // THEN the flags are set in environment
        XCTAssertEqual(AppEnvironment.value(for: "test1", provider: releaseFlag), true)
        XCTAssertEqual(AppEnvironment.value(for: "test2", provider: releaseFlag), false)
        
        let shouldBeNil: Bool? = AppEnvironment.value(for: "shouldBeNil", provider: ReleaseFlags())
        XCTAssertNil(shouldBeNil)
    }
    
    func test_defaultEnvironment_removingReleaseFlags() {
        // GIVEN there are release flags in Environment
        var releaseFlag = AppEnvironment
            .updateReleaseFlags(["test1": true, "test2": false])

        // WHEN updated to remove release flags from enviroment
        releaseFlag = AppEnvironment.updateReleaseFlags([:])

        // THEN the release flags are unset in the environment
        let testFlag1: Bool? = AppEnvironment.value(for: "test1", provider: releaseFlag)
        XCTAssertNil(testFlag1)

        let testFlag2: Bool? = AppEnvironment.value(for: "test2", provider: releaseFlag)
        XCTAssertNil(testFlag2)
    }
}
