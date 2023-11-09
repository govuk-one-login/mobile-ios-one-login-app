import GDSAnalytics
import GDSCommon
import Logging

struct AnalyticsButtonViewModel: ButtonViewModel {
    let title: GDSLocalisedString
    let icon: ButtonIconViewModel?
    let shouldLoadOnTap: Bool
    let action: (() -> Void)
    
    init(titleKey: String,
         _ titleStringVariableKeys: String...,
         icon: String? = nil,
         shouldLoadOnTap: Bool = false,
         analyticsService: AnalyticsService,
         action: @escaping () -> Void) {
        let event = ButtonEvent(textKey: titleKey, variableKeys: titleStringVariableKeys)
        self.init(titleKey: titleKey,
                  titleStringVariableKeys: titleStringVariableKeys,
                  analyticsService: analyticsService,
                  analyticsEvent: event,
                  action: action)
    }
    
    init(titleKey: String,
         titleStringVariableKeys: String...,
         icon: ButtonIconViewModel? = nil,
         shouldLoadOnTap: Bool = false,
         analyticsService: AnalyticsService,
         analyticsEvent: Event,
         action: @escaping () -> Void) {
        self.init(titleKey: titleKey,
                  titleStringVariableKeys: titleStringVariableKeys,
                  analyticsService: analyticsService,
                  analyticsEvent: analyticsEvent,
                  action: action)
    }
    
    private init(titleKey: String,
                 titleStringVariableKeys: [String],
                 icon: ButtonIconViewModel? = nil,
                 shouldLoadOnTap: Bool = false,
                 analyticsService: AnalyticsService,
                 analyticsEvent: Event,
                 action: @escaping () -> Void) {
        self.title = GDSLocalisedString(stringKey: titleKey, variableKeys: titleStringVariableKeys)
        self.icon = icon
        self.shouldLoadOnTap = shouldLoadOnTap
        self.action = {
            analyticsService.logEvent(analyticsEvent)
            
            action()
        }
    }
}
