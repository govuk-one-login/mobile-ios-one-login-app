import UIKit

let isRunningTests = ProcessInfo.processInfo.environment["IS_RUNNING_TESTS"] == "1"
let delegateClassName = isRunningTests
        ? NSStringFromClass(TestAppDelegate.self)
        : NSStringFromClass(AppDelegate.self)

UIApplicationMain(
    CommandLine.argc,
    CommandLine.unsafeArgv,
    nil,
    delegateClassName
)
