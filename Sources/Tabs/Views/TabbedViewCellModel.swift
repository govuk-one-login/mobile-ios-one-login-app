import GDSCommon
import UIKit

struct TabbedViewCellModel {
    let cellTitle: GDSLocalisedString?
    let textColor: UIColor
    let accessoryView: String?
    let action: (() -> Void)?
    let image: UIImage?
    
    init(cellTitle: GDSLocalisedString? = nil,
         image: UIImage? = nil,
         accessoryView: String? = nil,
         textColor: UIColor = .label,
         action: (() -> Void)? = nil) {
        self.cellTitle = cellTitle
        self.accessoryView = accessoryView
        self.textColor = textColor
        self.image = image
        self.action = action
    }
}
