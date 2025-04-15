import Foundation
import Networking

public protocol AppInformationProvider {
    func fetchAppInfo() async throws -> App
    func loadFromDefaults() async throws -> App
    var currentVersion: Version { get }
}

public final class AppInformationService: AppInformationProvider {
    private let client: NetworkClient
    private let baseURL: URL
    private let defaults: UserDefaults = .standard
    
    /// Initialise a new `AppInformationService`
    ///
    /// - Parameter baseURL: the host of the AppInformationService API
    public convenience init(baseURL: URL) {
        self.init(client: .init(), baseURL: baseURL)
    }
    
    init(client: NetworkClient, baseURL: URL) {
        self.client = client
        self.baseURL = baseURL
    }
    
    public var currentVersion: Version {
        guard let versionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"]
                as? String else { return .one }
        return Version(string: versionString) ?? .one
    }
    
    public func fetchAppInfo() async throws -> App {
        var request = URLRequest(url: baseURL)
        request.httpMethod = "GET"
        
        let data = try await client.makeRequest(request)
        defaults.set(data, forKey: baseURL.absoluteString)
        let appInfo = try parseResult(data).appList.iOS

        return appInfo
    }
    
    public func loadFromDefaults() async throws -> App {
        guard let cachedResponse = defaults.data(forKey: baseURL.absoluteString) else {
            return try await fetchAppInfo()
        }
        
        let appInfo = try parseResult(cachedResponse).appList.iOS
        return appInfo
    }
    
    private func parseResult(_ dataArray: Data) throws -> AppInfoResponse {
        try JSONDecoder().decode(AppInfoResponse.self, from: dataArray)
    }
}
