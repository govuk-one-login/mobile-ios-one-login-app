import FirebaseAppCheck
import FirebaseCore
import Networking

enum AppIntegrityError: Int, Error {
    case invalidPublicKey = 400
    case invalidToken = 401
}

public final class FirebaseAppIntegrityService: AppIntegrityProvider {
    let client: NetworkClient
    let vendor: AppCheckVendor

    // TODO: DCMAW-10322 | Return true if a valid (non-expired) attestation JWT is available
    private var isValidAttestationAvailable: Bool = false

    init(vendorType: AppCheckVendor.Type,
         providerFactory: AppCheckProviderFactory,
         client: NetworkClient) {
        vendorType.setAppCheckProviderFactory(providerFactory)
        self.client = client
        self.vendor = vendorType.appCheck()
    }

    public convenience init(
        client: NetworkClient
    ) {
        #if DEBUG
        let providerFactory = AppCheckDebugProviderFactory()
        #else
        let providerFactory = AppAttestProviderFactory()
        #endif
        self.init(
            vendorType: AppCheck.self,
            providerFactory: providerFactory,
            client: client
        )
    }

    func assertIntegrity() async throws {
        guard !isValidAttestationAvailable else {
            // nothing to do:
            return
        }

        let token = try await vendor.token(forcingRefresh: false)

        // Get the raw App Check token string.
        print("APP CHECK TOKEN:", token.token)

        // Include the App Check token with requests to your server.
        do {
            let data = try await client
                .makeRequest(.assert(token: token.token))
            print("APP CHECK SUCCESS:", String(decoding: data, as: UTF8.self))

            // TODO: decode this from the following structure:
            /*
             {
              "client_attestation": "eyJ...", /* Client Attestation JWT signed by Mobile Backend signing key */
              "expires_in": 86400 /* One day in seconds */
            }
             */

            // TODO: store this locally
        } catch let error as ServerError where
                    error.errorCode == 400 {
            throw AppIntegrityError.invalidPublicKey
        } catch let error as ServerError where
                    error.errorCode == 401 {
            throw AppIntegrityError.invalidToken
        }
    }

    public func addIntegrityAssertions(to request: URLRequest) -> URLRequest {
        var signedRequest = request
        signedRequest.addValue("abc",
                               forHTTPHeaderField: "OAuth-Client-Attestation")
        signedRequest.addValue("def",
                               forHTTPHeaderField: "OAuth-Client-Attestation-PoP")
        return request
    }
}
