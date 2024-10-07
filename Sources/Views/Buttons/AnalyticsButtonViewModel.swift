import GDSAnalytics
import GDSCommon
import Logging
import UIKit

struct AnalyticsButtonViewModel: ColoredButtonViewModel {
    let title: GDSLocalisedString
    let icon: ButtonIconViewModel?
    let backgroundColor: UIColor
    let shouldLoadOnTap: Bool
    let action: (() -> Void)
    
    init(titleKey: String,
         _ titleStringVariableKeys: String...,
         backgroundColor: UIColor = .gdsGreen,
         shouldLoadOnTap: Bool = false,
         analyticsService: AnalyticsService,
         action: @escaping () -> Void) {
        let event = ButtonEvent(textKey: titleKey, variableKeys: titleStringVariableKeys)
        self.init(titleKey: titleKey,
                  titleStringVariableKeys: titleStringVariableKeys,
                  backgroundColor: backgroundColor,
                  analyticsService: analyticsService,
                  analyticsEvent: event,
                  action: action)
    }
    
    init(titleKey: String,
         titleStringVariableKeys: String...,
         icon: ButtonIconViewModel? = nil,
         backgroundColor: UIColor = .gdsGreen,
         shouldLoadOnTap: Bool = false,
         analyticsService: AnalyticsService,
         analyticsEvent: Event,
         action: @escaping () -> Void) {
        self.init(titleKey: titleKey,
                  titleStringVariableKeys: titleStringVariableKeys,
                  icon: icon,
                  backgroundColor: backgroundColor,
                  analyticsService: analyticsService,
                  analyticsEvent: analyticsEvent,
                  action: action)
    }
    
    private init(titleKey: String,
                 titleStringVariableKeys: [String],
                 icon: ButtonIconViewModel? = nil,
                 backgroundColor: UIColor = .gdsGreen,
                 shouldLoadOnTap: Bool = false,
                 analyticsService: AnalyticsService,
                 analyticsEvent: Event,
                 action: @escaping () -> Void) {
        self.title = GDSLocalisedString(stringKey: titleKey, variableKeys: titleStringVariableKeys)
        self.icon = icon
        self.backgroundColor = backgroundColor
        self.shouldLoadOnTap = shouldLoadOnTap
        self.action = {
            analyticsService.logEvent(analyticsEvent)
            
            action()
        }
    }
}
