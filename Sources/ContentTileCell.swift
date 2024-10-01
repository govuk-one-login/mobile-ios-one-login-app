import GAnalytics
import GDSCommon
import Logging
import UIKit

class ContentTileCell: UITableViewCell {
//    var analyticsService: AnalyticsService
    
//    init(analyticsService: AnalyticsService) {
//        super.init(style: .default, reuseIdentifier: "", self.analyticsService = analyticsService)
//        self.analyticsService = analyticsService
//    }
    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    let cellView: UIView = {
        let analyticsService = GAnalytics()
        let viewModel = ContentTileViewModel(analyticsService: analyticsService, action: { })
        let frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        let view = GDSContentTileView(frame: frame, viewModel: viewModel)
//        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func layoutIfNeeded() {
        addSubview(cellView)
        NSLayoutConstraint.activate([
            cellView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cellView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            cellView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            cellView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor)
        ])
        super.layoutIfNeeded()
    }
}
