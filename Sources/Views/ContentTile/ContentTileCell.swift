import DesignSystem
import GAnalytics
import Logging
import UIKit

final class ContentTileCell: UITableViewCell {
    var viewModel: GDSCardViewModel? {
        didSet {
            guard let viewModel else { return }
            let view = GDSCard(viewModel: viewModel)
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
