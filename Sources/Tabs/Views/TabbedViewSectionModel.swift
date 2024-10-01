import Foundation
import GDSCommon

struct TabbedViewSectionModel {
    let sectionTitle: GDSLocalisedString?
    let sectionFooter: GDSLocalisedString?
    let tabModels: [TabbedViewCellModel]
    
    init(sectionTitle: GDSLocalisedString? = nil,
         sectionFooter: GDSLocalisedString? = nil,
         tabModels: [TabbedViewCellModel] = [TabbedViewCellModel]()) {
        self.sectionTitle = sectionTitle
        self.sectionFooter = sectionFooter
        self.tabModels = tabModels
    }
}

struct ContentViewSectionModel {
    let tabModels: [ContentViewCellModel]
    
    init(tabModels: [ContentViewCellModel] = [ContentViewCellModel]()) {
        self.tabModels = tabModels
    }
}
