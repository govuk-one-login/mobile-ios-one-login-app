public protocol LocalAuthenticationManager {
    associatedtype LAType: LocalAuthType
    var type: LAType { get }
    
    func checkLevelSupported(_ requiredLevel: LAType) -> Bool
    func enrolFaceIDIfAvailable() async throws -> Bool
}
