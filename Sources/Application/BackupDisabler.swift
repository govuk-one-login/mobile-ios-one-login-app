import Foundation

protocol BackupDisabler {
    func disableFileBackup(fileManager: AppFileManager)
}

extension BackupDisabler {
    func disableFileBackup(fileManager: AppFileManager = FileManager.default) {
        var values = URLResourceValues()
        values.isExcludedFromBackup = true
        
        if var url = try? fileManager.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ) {
            try? url.setResourceValues(values)
        }
    }
}
