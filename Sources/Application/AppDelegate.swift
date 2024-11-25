import AppIntegrity
import GAnalytics
import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print("APP CHECK DEBUG TOKEN", ProcessInfo.processInfo.environment["FIRAAppCheckDebugToken"])
        print("APP CHECK LAUNCH ARGUMENTS", ProcessInfo.processInfo.arguments)
        FirebaseAppIntegrityService.configure()
        GAnalytics().configure()
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration",
                                    sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication,
                     didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
    
}
