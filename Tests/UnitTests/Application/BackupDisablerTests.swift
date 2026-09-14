import Foundation
@testable import OneLogin
import Testing

struct BackupDisablerTests: BackupDisabler {
    @Test
    func documentsFolderBackupsDisabled() throws {
        disableFileBackup()
        
        let url: URL = try #require(try? FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ))
        
        let values = try? url.resourceValues(
            forKeys: [.isExcludedFromBackupKey]
        )
        
        #expect(values?.isExcludedFromBackup == true)
    }
    
    @Test
    func disableBackup() throws {
        let sut = MockBackupDisabler()
        
        let documentsDirectory = try #require(try? FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ))
        
        let directoryURL = documentsDirectory.appendingPathComponent("test")
        try? FileManager.default.removeItem(at: directoryURL)
        
        let mockFileManager = MockFileManager()
        mockFileManager.customURL = directoryURL
        try mockFileManager.createDirectory()
        
        #expect(!mockFileManager.isExcludedFromBackup())
        sut.disableFileBackup(fileManager: mockFileManager)
        #expect(mockFileManager.isExcludedFromBackup())
        
        try? FileManager.default.removeItem(at: directoryURL)
    }
}
