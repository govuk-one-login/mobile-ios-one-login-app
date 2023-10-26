import Foundation

extension String {
    static let oneLoginClientID: String = "sdJChz1oGajIz0O0tdPdh0CA2zW"
    
    static var oneLoginRedirect: String {
        return AppEnvironment.string(for: .redirectURL)
    }
}
