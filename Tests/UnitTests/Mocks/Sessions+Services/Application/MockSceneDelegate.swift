import Logging
@testable import OneLogin
import UIKit

class MockSceneDelegate: SceneLifecycle {
    var coordinator: MainCoordinator?
    var analyticsService: AnalyticsService
    
    init(coordinator: MainCoordinator?,
         analyticsService: AnalyticsService) {
        self.coordinator = coordinator
        self.analyticsService = analyticsService
    }
}
