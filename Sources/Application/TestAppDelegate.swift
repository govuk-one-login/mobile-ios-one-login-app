import UIKit

class TestAppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UIView.setAnimationsEnabled(false)
        removeCachedScenes(from: application)
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let sceneConfiguration = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        sceneConfiguration.delegateClass = TestingSceneDelegate.self
        return sceneConfiguration
    } 

    private func removeCachedScenes(from application: UIApplication) {
        /* Remove any cached scene configurations to ensure that
         TestingAppDelegate.application(_:configurationForConnecting:options:) is called
         and TestingSceneDelegate will be used when running unit tests.
         
         Warning: This is a private API and may break in the future.
         It is perfectly app-store safe since it is not included in the main app targets. */
        for sceneSession in application.openSessions {
            application.perform(Selector(("_removeSessionFromSessionSet:")), with: sceneSession)
        }
    }
}

public final class TestingSceneDelegate: UIResponder, UIWindowSceneDelegate {
    
}
