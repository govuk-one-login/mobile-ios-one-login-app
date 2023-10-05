import GAnalytics
import GDSAnalytics
import GDSCommon
import Logging
import UIKit

struct OneLoginWelcomeViewModel: WelcomeViewModel {
    var image: UIImage = UIImage(named: "badge") ?? UIImage()
    var title: GDSLocalisedString = "GOV.UK One Login"
    var body: GDSLocalisedString = "This is a short description of the GOV.UK One Login application as a demonstration of the screen"
    var welcomeButtonViewModel: ButtonViewModel = AnalyticsButtonViewModel(titleKey: "Continue",
                                                                           analyticsService: GAnalytics(),
                                                                           action: { })
    
    func didAppear() { }
}
