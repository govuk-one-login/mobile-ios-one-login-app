import Foundation
import OneLogin

class MockFileManager: AppFileManager {
    var customURL: URL?
    
    func createDirectory() throws {
        if let customURL {
            try FileManager.default.createDirectory(
                at: customURL,
                withIntermediateDirectories: false
            )
        } else {
            throw NSError(domain: "MockFileManager", code: 0, userInfo: nil)
        }
    }
    
    func url(
        for directory: FileManager.SearchPathDirectory,
        in domain: FileManager.SearchPathDomainMask,
        appropriateFor url: URL?,
        create shouldCreate: Bool
    ) throws -> URL {
        if let customURL {
            return customURL
        } else {
            throw NSError(domain: "MockFileManager", code: 0, userInfo: nil)
        }
    }
    
    func isExcludedFromBackup() -> Bool {
        let values = try? customURL?.resourceValues(
            forKeys: [.isExcludedFromBackupKey]
        )
        
        return values?.isExcludedFromBackup ?? false
    }
}
