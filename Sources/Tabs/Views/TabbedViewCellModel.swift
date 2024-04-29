import Foundation
import GDSCommon

struct TabbedViewCellModel {
    var cellTitle: GDSLocalisedString?
    var action: (() -> Void)?
    
    init(cellTitle: GDSLocalisedString? = nil, action: (() -> Void)? = nil) {
        self.cellTitle = cellTitle
        self.action = action
    }
}
