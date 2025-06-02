import UIKit

final class TabbedTableViewCell: UITableViewCell, ViewIdentifiable {
    var viewModel: TabbedViewCellModel? {
        didSet {
            var cellConfig = defaultContentConfiguration()
            cellConfig.text = viewModel?.cellTitle?.value
            cellConfig.textProperties.color = viewModel?.textColor ?? .label
            cellConfig.secondaryText = viewModel?.cellSubtitle
            cellConfig.secondaryTextProperties.color = .gdsGrey
            cellConfig.image = viewModel?.image
            contentConfiguration = cellConfig
            
            guard let viewName = viewModel?.accessoryView else { return }
            let config = UIImage.SymbolConfiguration(textStyle: .body)
            var accessoryImage = UIImage(systemName: viewName)
            accessoryImage = accessoryImage?.applyingSymbolConfiguration(config)
            let imageView = UIImageView(image: accessoryImage)
            accessoryView = imageView
            accessoryView?.tintColor = .secondaryLabel
            accessibilityHint = viewModel?.accessibilityHint?.value
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        if selected {
            isHighlighted = false
        }
    }
}
