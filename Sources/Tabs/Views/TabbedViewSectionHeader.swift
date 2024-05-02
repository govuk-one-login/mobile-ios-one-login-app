import GDSCommon
import UIKit

final class TabbedViewSectionHeader: UITableViewHeaderFooterView, ViewIdentifiable {
    var title: GDSLocalisedString? {
        didSet {
            textLabel?.text = title?.value
            textLabel?.font = .bodyBold
            textLabel?.textColor = .label
            textLabel?.adjustsFontForContentSizeCategory = true
        }
    }
}
