import Foundation

public struct Service {
    private(set) static var baseURL: URL!
    
    public static func initialize(baseURL: URL) {
        self.baseURL = baseURL
    }
}
