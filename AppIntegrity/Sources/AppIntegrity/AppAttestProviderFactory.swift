import FirebaseAppCheck
import FirebaseCore

@available(iOS 14, *)
final class AppAttestProviderFactory: NSObject,
                                      AppCheckProviderFactory {
    func createProvider(with app: FirebaseApp) -> AppCheckProvider? {
        AppAttestProvider(app: app)
    }
}
