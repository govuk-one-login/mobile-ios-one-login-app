import LocalAuthentication
@testable import LocalAuthenticationWrapper
@testable import OneLogin
import SecureStore
import Testing

struct LocalAuthenticationContextStringsTests {
    @Test
    func assert_oneLoginStrings() throws {
        let localAuthContext: MockLocalAuthContext = .stub(biometryType: .faceID)
        let localAuthWrapper = LocalAuthenticationWrapper.make(
            localAuthContext: localAuthContext,
            localAuthPromptStore: UserDefaults.standard
        )

        let oneLoginStrings = try localAuthWrapper.oneLoginStrings

        let expected: LocalAuthenticationLocalizedStrings = LocalAuthenticationLocalizedStrings(
            localizedReason: "Enter iPhone passcode",
            localisedFallbackTitle: "Enter passcode",
            localisedCancelTitle: "Cancel"
        )

        #expect(oneLoginStrings == expected)
    }

    @Test
    func assert_oneLoginStrings_forNone() {
        let localAuthWrapper = LocalAuthenticationWrapper.make(
            localAuthContext: LAContext(),
            localAuthPromptStore: UserDefaults.standard
        )

        let oneLoginStrings = localAuthWrapper.oneLoginStrings(type: .none)

        let expected: LocalAuthenticationLocalizedStrings = LocalAuthenticationLocalizedStrings(
            localizedReason: "Unlock to proceed",
            localisedFallbackTitle: "Enter passcode",
            localisedCancelTitle: "Cancel"
        )

        #expect(oneLoginStrings == expected)
    }
}
