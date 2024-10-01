import UIKit

 final class ContentTableViewCell: UITableViewCell, ViewIdentifiable {
    var viewModel: ContentViewCellModel? {
        didSet {
            textLabel?.text = "test test test"
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        if selected {
            isHighlighted = false
        }
    }
 }
