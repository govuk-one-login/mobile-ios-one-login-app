public protocol LocalAuthWrap {
    var type: LocalAuthType { get throws }
    
    func checkMinimumLevel(_ requiredLevel: RequiredLocalAuthLevel) throws -> Bool
    func promptForPermissions() async throws -> Bool
}
