public protocol LocalAuthenticationManager {
    associatedtype LAType: LocalAuthType
    var type: LAType { get }
    
    func checkMinimumLevel(_ requiredLevel: any LocalAuthType) -> Bool
    func enrolLocalAuth() async throws -> Bool
}
