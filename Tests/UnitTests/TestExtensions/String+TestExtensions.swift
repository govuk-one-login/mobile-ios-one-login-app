import GDSCommon

extension String {
    func getEnglishString() -> String {
        NSLocalizedString(key: self, tableName: "en.lproj/Localizable", comment: "")
    }
    
    func getWelshString() -> String {
        NSLocalizedString(key: self, tableName: "cy-GB.lproj/Localizable", comment: "")
    }
}
