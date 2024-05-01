import GDSCommon
import UIKit

final class TabbedViewSectionHeader: NibView {
    private let title: GDSLocalisedString?
    
    init(title: GDSLocalisedString? = nil) {
        self.title = title
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBOutlet private var sectionTitleLabel: UILabel! {
        didSet {
            sectionTitleLabel.font = .bodyBold
            sectionTitleLabel.text = title?.value
        }
    }
}
