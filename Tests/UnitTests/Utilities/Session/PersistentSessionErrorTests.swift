@testable import OneLogin
import Testing

struct PersistentSessionErrorTests {
    
    struct Case: Sendable {
        let error: PersistentSessionError
        let debugDescription: String
        let kind: String
    }

    // swiftlint:disable line_length
    static let allPersistentSessionError = [
        Case(error: PersistentSessionError(.noSessionExists), debugDescription: "Error Domain=PersistentSessionErrorKind Code=1001 \"there was no persistentID token saved in the encrypted store\"", kind: "noSessionExists"),
        Case(error: PersistentSessionError(.userRemovedLocalAuth), debugDescription: "Error Domain=PersistentSessionErrorKind Code=1002 \"the user has removed all local auth from their device\"", kind: "userRemovedLocalAuth"),
        Case(error: PersistentSessionError(.sessionMismatch), debugDescription: "Error Domain=PersistentSessionErrorKind Code=1003 \"the persistentID was cleared from the encrypted store because a different user logged in\"", kind: "sessionMismatch"),
        Case(error: PersistentSessionError(.cannotDeleteData), debugDescription: "Error Domain=PersistentSessionErrorKind Code=1004 \"there was an error while trying to delete all user data\"", kind: "cannotDeleteData"),
        Case(error: PersistentSessionError(.idTokenNotStored), debugDescription: "Error Domain=PersistentSessionErrorKind Code=1005 \"there was no idToken found in the secure store\"", kind: "idTokenNotStored")
    ]
    // swiftlint:enable line_length

    @Test("assert debugDescription", arguments: PersistentSessionErrorTests.allPersistentSessionError)
    func test_debugDescription(testCase: Case) async throws {
        #expect(testCase.error.debugDescription == testCase.debugDescription)
    }
    
    /// // swiftlint:disable line_length
    /// The `kind` found in the `userInfo` **must** hold a unique String identifier that describes the error as reported on analytics
    /// - Seealso: https://govukverify.atlassian.net/wiki/x/OgS84Q
    /// // swiftlint:enable line_length
    @Test("assert kind", arguments: PersistentSessionErrorTests.allPersistentSessionError)
    func test_kind(testCase: Case) async throws {
        #expect(testCase.error.errorUserInfo["kind"] as? String == testCase.kind)
    }

}
