import GDSUtilities

extension ErrorKind {
    public enum OneLogin: String, AnyErrorKind {
        case accountIntervention = "User has an account intervention in place"
    }
}

public typealias OneLoginError = GDSError<ErrorKind.OneLogin>

extension OneLoginError where Kind == ErrorKind.OneLogin {
    public init(
        _ kind: ErrorKind.OneLogin,
        reason: String? = nil,
        endpoint: String? = nil,
        statusCode: Int? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line,
        resolvable: Bool = true,
        originalError: Error? = nil,
        additionalParameters: [String: any Sendable] = [:]
    ) {
        self.init(
            kind: kind,
            reason: reason,
            endpoint: endpoint,
            statusCode: statusCode,
            file: file,
            function: function,
            line: line,
            resolvable: resolvable,
            originalError: originalError,
            additionalParameters: additionalParameters
        )
    }
}
