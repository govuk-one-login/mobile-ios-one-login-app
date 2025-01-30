public protocol LocalAuthenticationManager {
    associatedtype LAType: LocalAuthType
    var type: LAType { get }
    
    func checkLevelSupported(_ requiredLevel: any LocalAuthType) -> Bool
    func enrolFaceIDIfAvailable() async throws -> Bool
}
