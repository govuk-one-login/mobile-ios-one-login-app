import GDSCommon

extension String {
    func getEnglishString() -> String {
        return NSLocalizedString(key: self, tableName: "en.lproj/Localizable", comment: "")
    }
    
    func getWelshString() -> String {
        return NSLocalizedString(key: self, tableName: "cy-GB.lproj/Localizable", comment: "")
    }
}
