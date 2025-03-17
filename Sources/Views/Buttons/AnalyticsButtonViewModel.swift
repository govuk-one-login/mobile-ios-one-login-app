import GDSAnalytics
import GDSCommon
import Logging
import UIKit

struct AnalyticsButtonViewModel: ColoredButtonViewModel {
    let accessibilityHint: GDSLocalisedString?
    let title: GDSLocalisedString
    let icon: ButtonIconViewModel?
    let backgroundColor: UIColor
    var shouldLoadOnTap: Bool = false
    let action: (() -> Void)
    
    init(titleKey: String,
         _ titleStringVariableKeys: String...,
         icon: ButtonIconViewModel? = nil,
         backgroundColor: UIColor = .gdsGreen,
         analyticsService: AnalyticsService,
         accessibilityHint: GDSLocalisedString? = nil,
         action: @escaping () -> Void) {
        let event = ButtonEvent(textKey: titleKey,
                                variableKeys: titleStringVariableKeys)
        self.init(titleKey: titleKey,
                  titleStringVariableKeys: titleStringVariableKeys,
                  backgroundColor: backgroundColor,
                  analyticsService: analyticsService,
                  analyticsEvent: event,
                  accessibilityHint: accessibilityHint,
                  action: action)
    }
    
    init(titleKey: String,
         _ titleStringVariableKeys: String...,
         icon: ButtonIconViewModel? = nil,
         backgroundColor: UIColor = .gdsGreen,
         shouldLoadOnTap: Bool = false,
         analyticsService: AnalyticsService,
         analyticsEvent: Event,
         accessibilityHint: GDSLocalisedString? = nil,
         action: @escaping () -> Void) {
        self.init(titleKey: titleKey,
                  titleStringVariableKeys: titleStringVariableKeys,
                  icon: icon,
                  backgroundColor: backgroundColor,
                  analyticsService: analyticsService,
                  analyticsEvent: analyticsEvent,
                  accessibilityHint: accessibilityHint,
                  action: action)
    }
    
    private init(titleKey: String,
                 titleStringVariableKeys: [String],
                 icon: ButtonIconViewModel? = nil,
                 backgroundColor: UIColor = .gdsGreen,
                 shouldLoadOnTap: Bool = false,
                 analyticsService: AnalyticsService,
                 analyticsEvent: Event,
                 accessibilityHint: GDSLocalisedString? = nil,
                 action: @escaping () -> Void) {
        self.title = GDSLocalisedString(stringKey: titleKey, variableKeys: titleStringVariableKeys)
        self.icon = icon
        self.backgroundColor = backgroundColor
        self.shouldLoadOnTap = shouldLoadOnTap
        self.accessibilityHint = accessibilityHint
        self.action = {
            analyticsService.logEvent(analyticsEvent)
            
            action()
        }
    }
}
