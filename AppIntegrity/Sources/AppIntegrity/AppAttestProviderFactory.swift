import FirebaseAppCheck
import FirebaseCore

final class AppAttestProviderFactory: NSObject,
                                      AppCheckProviderFactory {
    func createProvider(with app: FirebaseApp) -> AppCheckProvider? {
        AppAttestProvider(app: app)
    }
}
