import GDSCommon
import UIKit

final class TabbedViewModel: NSObject, BaseViewModel {
    var rightBarButtonTitle: GDSCommon.GDSLocalisedString?
    var backButtonIsHidden: Bool
    var title: String?
    var dataSource: UITableViewDataSource?
    
    init(rightBarButtonTitle: GDSCommon.GDSLocalisedString? = nil, backButtonIsHidden: Bool = true, title: String? = nil, dataSource: UITableViewDataSource? = nil) {
        self.rightBarButtonTitle = rightBarButtonTitle
        self.backButtonIsHidden = backButtonIsHidden
        self.title = title
        self.dataSource = dataSource
    }
    
    func didAppear() {
        
    }
    
    func didDismiss() {
        
    }
}

extension TabbedViewModel: UITableViewDelegate {
    
}
