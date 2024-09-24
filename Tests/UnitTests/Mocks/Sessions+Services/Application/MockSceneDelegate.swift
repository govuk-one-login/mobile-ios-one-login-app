import Logging
@testable import OneLogin
import UIKit

class MockSceneDelegate: SceneLifecycle {
    var coordinator: TabManagerCoordinator?
    var analyticsService: AnalyticsService
    
    init(coordinator: TabManagerCoordinator?,
         analyticsService: AnalyticsService) {
        self.coordinator = coordinator
        self.analyticsService = analyticsService
    }
}
