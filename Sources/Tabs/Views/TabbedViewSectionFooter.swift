import GDSCommon
import UIKit

final class TabbedViewSectionFooter: UITableViewHeaderFooterView, ViewIdentifiable {
    var title: GDSLocalisedString? {
        didSet {
            textLabel?.numberOfLines = 0
            textLabel?.lineBreakMode = .byWordWrapping
            if let attributedValue = title?.attributedValue {
                textLabel?.attributedText = attributedValue
            } else {
                textLabel?.text = title?.value
            }
            textLabel?.font = .footnote
            textLabel?.textColor = .secondaryLabel
            textLabel?.adjustsFontForContentSizeCategory = true
        }
    }
}
