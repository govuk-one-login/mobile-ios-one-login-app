import GAnalytics
import GDSAnalytics
import GDSCommon
import Logging
import UIKit

struct OneLoginWelcomeViewModel: WelcomeViewModel {
    var image: UIImage = UIImage(named: "badge") ?? UIImage()
    var title: GDSLocalisedString = ""
    var body: GDSLocalisedString = ""
    var welcomeButtonViewModel: ButtonViewModel = AnalyticsButtonViewModel(titleKey: "",
                                                                           analyticsService: GAnalytics(),
                                                                           action: { })
    
    func didAppear() { }
}
