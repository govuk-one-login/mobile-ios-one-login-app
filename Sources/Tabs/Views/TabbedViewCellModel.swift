import Foundation
import GDSCommon

struct TabbedViewCellModel {
    let cellTitle: GDSLocalisedString?
    let action: (() -> Void)?
    
    init(cellTitle: GDSLocalisedString? = nil, action: (() -> Void)? = nil) {
        self.cellTitle = cellTitle
        self.action = action
    }
}
