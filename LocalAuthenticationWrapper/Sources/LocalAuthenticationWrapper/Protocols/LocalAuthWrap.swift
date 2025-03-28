public protocol LocalAuthWrap {
    var type: LocalAuthType { get throws }
    
    func checkMinimumLevel(_ requiredLevel: RequiredLocalAuthLevel) throws -> Bool
    func enrolLocalAuth() async throws -> Bool
}
