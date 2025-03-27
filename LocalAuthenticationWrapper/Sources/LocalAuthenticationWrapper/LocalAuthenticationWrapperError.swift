public enum LocalAuthenticationWrapperError: Error {
    case biometricsUnavailable
    case cancelled
    case generic(description: String)
}
