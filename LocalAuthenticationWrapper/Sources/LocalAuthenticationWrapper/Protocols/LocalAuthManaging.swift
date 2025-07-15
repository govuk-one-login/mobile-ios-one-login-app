public protocol LocalAuthManaging {
    var type: LocalAuthType { get throws }
    var deviceBiometricsType: LocalAuthType { get }
    var canUseAnyLocalAuth: Bool { get throws }
    
    func checkLevelSupported(_ requiredLevel: RequiredLocalAuthLevel) throws -> Bool
    func promptForPermission() async throws -> Bool
    func hasBeenPrompted() -> Bool
}
