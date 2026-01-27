import GDSUtilities

enum OneLoginErrorKind: String, GDSErrorKind {
    case accountIntervention = "User has an account intervention in place"
}

typealias OneLoginError = OneLoginGDSError<OneLoginErrorKind>

struct OneLoginGDSError<Kind: GDSErrorKind>: GDSError {
    let kind: Kind
    let reason: String?
    let endpoint: String?
    let statusCode: Int?
    let file: String
    let function: String
    let line: Int
    let resolvable: Bool
    let originalError: (any Error)?
    let additionalParameters: [String: any Sendable]

    init(
        _ kind: Kind,
        reason: String? = nil,
        endpoint: String? = nil,
        statusCode: Int? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line,
        resolvable: Bool = false,
        originalError: (any Error)? = nil,
        additionalParameters: [String: any Sendable] = [:]
    ) {
        self.kind = kind
        self.reason = reason
        self.endpoint = endpoint
        self.statusCode = statusCode
        self.file = file
        self.function = function
        self.line = line
        self.resolvable = resolvable
        self.originalError = originalError
        self.additionalParameters = additionalParameters
    }
}
