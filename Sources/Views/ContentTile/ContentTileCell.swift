import GAnalytics
import GDSCommon
import Logging
import UIKit

final class ContentTileCell: UITableViewCell {
    var viewModel: GDSContentTileViewModel? {
        didSet {
            guard let viewModel else { return }
            let view = GDSContentTileView(viewModel: viewModel)
            view.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(view)
            
            NSLayoutConstraint.activate([
                view.topAnchor.constraint(equalTo: contentView.topAnchor),
                view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
            ])
        }
    }
}
