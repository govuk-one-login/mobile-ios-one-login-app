@testable import OneLogin
import Testing

struct PersistentSessionErrorTests {
    // swiftlint:disable line_length
    static let allPersistentSessionError = [
        (error: PersistentSessionError(.noSessionExists), debugDescription: "Error Domain=PersistentSessionErrorKind Code=1001 \"there was no persistentID token saved in the encrypted store\""),
        (error: PersistentSessionError(.userRemovedLocalAuth), debugDescription: "Error Domain=PersistentSessionErrorKind Code=1002 \"the user has removed all local auth from their device\""),
        (error: PersistentSessionError(.sessionMismatch), debugDescription: "Error Domain=PersistentSessionErrorKind Code=1003 \"the persistentID was cleared from the encrypted store because a different user logged in\""),
        (error: PersistentSessionError(.cannotDeleteData), debugDescription: "Error Domain=PersistentSessionErrorKind Code=1004 \"there was an error while trying to delete all user data\""),
        (error: PersistentSessionError(.idTokenNotStored), debugDescription: "Error Domain=PersistentSessionErrorKind Code=1005 \"there was no idToken found in the secure store\"")
    ]
    // swiftlint:enable line_length

    @Test("assert debugDescription matches reason", arguments: PersistentSessionErrorTests.allPersistentSessionError)
    func test_debugDescription(sut: PersistentSessionError, debugDescription: String) async throws {
        #expect(sut.debugDescription == debugDescription)
    }
}
