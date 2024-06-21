import Logging
#if NOW
@testable import OneLoginNOW
#else
@testable import OneLogin
#endif

import UIKit

class MockSceneDelegate: SceneLifecycle {
    var coordinator: MainCoordinator?
    var analyticsService: AnalyticsService
    var windowManager: WindowManagement?
    
    init(coordinator: MainCoordinator?,
         analyticsService: AnalyticsService,
         windowManager: WindowManagement) {
        self.coordinator = coordinator
        self.analyticsService = analyticsService
        self.windowManager = windowManager
    }
}
