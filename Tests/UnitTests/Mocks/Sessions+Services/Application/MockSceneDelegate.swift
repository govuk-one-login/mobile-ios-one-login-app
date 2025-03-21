import Logging
@testable import OneLogin
import UIKit

class MockSceneDelegate: SceneLifecycle {
    var coordinator: TabManagerCoordinator?
    var analyticsService: OneLoginAnalyticsService
    
    init(coordinator: TabManagerCoordinator?,
         analyticsService: OneLoginAnalyticsService) {
        self.coordinator = coordinator
        self.analyticsService = analyticsService
    }
}
