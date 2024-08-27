import Foundation

extension Date {
    @backDeployed(before: iOS 15)
    public static var now: Date {
        Date()
    }
}
