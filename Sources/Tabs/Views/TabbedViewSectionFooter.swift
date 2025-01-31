import GDSCommon
import UIKit

final class TabbedViewSectionFooter: UITableViewHeaderFooterView, ViewIdentifiable {
    var title: GDSLocalisedString? {
        didSet {
            textLabel?.numberOfLines = 0
            textLabel?.lineBreakMode = .byWordWrapping
            textLabel?.text = title?.value
            textLabel?.font = .footnote
            textLabel?.textColor = .secondaryLabel
            textLabel?.adjustsFontForContentSizeCategory = true
        }
    }
}
