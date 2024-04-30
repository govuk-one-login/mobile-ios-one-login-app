import Foundation
import GDSCommon

struct TabbedViewSectionFactory {

    static func createSection(header: GDSLocalisedString?,
                              footer: GDSLocalisedString?,
                              cellModels: [TabbedViewCellModel]) -> TabbedViewSectionModel {
        
        return TabbedViewSectionModel(sectionTitle: header,
                                      sectionFooter: footer,
                                      tabModels: cellModels)
        
    }
    
    
}
