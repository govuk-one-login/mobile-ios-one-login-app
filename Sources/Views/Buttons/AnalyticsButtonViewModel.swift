import GDSAnalytics
import GDSCommon
import Logging
import UIKit

struct AnalyticsButtonViewModel: ColoredButtonViewModel {
    let title: GDSLocalisedString
    let icon: ButtonIconViewModel?
    let backgroundColor: UIColor
    let shouldLoadOnTap: Bool
    let accessibilityHint: GDSLocalisedString?
    let action: (() -> Void)
    
    init(titleKey: String,
         _ titleStringVariableKeys: String...,
         icon: ButtonIconViewModel? = nil,
         backgroundColor: UIColor = .accent,
         shouldLoadOnTap: Bool = false,
         accessibilityHint: GDSLocalisedString? = nil,
         analyticsService: OneLoginAnalyticsService,
         action: @escaping () -> Void) {
        let event = ButtonEvent(textKey: titleKey,
                                variableKeys: titleStringVariableKeys)
        self.init(titleKey: titleKey,
                  titleStringVariableKeys: titleStringVariableKeys,
                  icon: icon,
                  backgroundColor: backgroundColor,
                  shouldLoadOnTap: shouldLoadOnTap,
                  analyticsService: analyticsService,
                  analyticsEvent: event,
                  accessibilityHint: accessibilityHint,
                  action: action)
    }
    
    init(titleKey: String,
         _ titleStringVariableKeys: String...,
         icon: ButtonIconViewModel? = nil,
         backgroundColor: UIColor = .accent,
         shouldLoadOnTap: Bool = false,
         analyticsService: OneLoginAnalyticsService,
         analyticsEvent: Event,
         accessibilityHint: GDSLocalisedString? = nil,
         action: @escaping () -> Void) {
        self.init(titleKey: titleKey,
                  titleStringVariableKeys: titleStringVariableKeys,
                  icon: icon,
                  backgroundColor: backgroundColor,
                  shouldLoadOnTap: shouldLoadOnTap,
                  analyticsService: analyticsService,
                  analyticsEvent: analyticsEvent,
                  accessibilityHint: accessibilityHint,
                  action: action)
    }
    
    private init(titleKey: String,
                 titleStringVariableKeys: [String],
                 icon: ButtonIconViewModel? = nil,
                 backgroundColor: UIColor = .accent,
                 shouldLoadOnTap: Bool = false,
                 analyticsService: OneLoginAnalyticsService,
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
