@testable import OneLogin
import Testing

struct PersistentSessionErrorTests {
    // swiftlint:disable line_length
    static let allPersistentSessionError = [
        (error: PersistentSessionError(.noSessionExists, reason: "there was no persistentID token saved in the encrypted store"), debugDescription: "there was no persistentID token saved in the encrypted store"),
        (error: PersistentSessionError(.userRemovedLocalAuth, reason: "the user has removed all local auth from their device"), debugDescription: "the user has removed all local auth from their device"),
        (error: PersistentSessionError(.sessionMismatch, reason: "the persistentID was cleared from the encrypted store because a different user logged in"), debugDescription: "the persistentID was cleared from the encrypted store because a different user logged in"),
        (error: PersistentSessionError(.cannotDeleteData, reason: "there was an error while trying to delete all user data"), debugDescription: "there was an error while trying to delete all user data"),
        (error: PersistentSessionError(.idTokenNotStored, reason: "there was no idToken found in the secure store"), debugDescription: "there was no idToken found in the secure store")
    ]
    // swiftlint:enable line_length

    @Test("assert debugDescription matches reason", arguments: PersistentSessionErrorTests.allPersistentSessionError)
    func test_debugDescription(sut: PersistentSessionError, debugDescription: String) async throws {
        #expect(sut.debugDescription == debugDescription)
    }
}
