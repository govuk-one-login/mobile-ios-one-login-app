import Foundation
import Networking

public protocol AppInformationProvider {
    func fetchAppInfo() async throws -> App
    var currentVersion: Version { get }
}

public enum AppInfoError: Error {
    case invalidResponse
}

public final class AppInformationService: AppInformationProvider {
    private let client: NetworkClient
    private let baseURL: URL
    private let cache: UserDefaults
    
    /// Initialise a new `AppInformationService`
    ///
    /// - Parameter baseURL: the host of the AppInformationService API
    public convenience init(baseURL: URL) {
        self.init(client: .init(), baseURL: baseURL)
    }
    
    init(client: NetworkClient, baseURL: URL, cache: UserDefaults = .standard) {
        self.client = client
        self.baseURL = baseURL
        self.cache = cache
    }
    
    public var currentVersion: Version {
        guard let versionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"]
                as? String else { return .one }
        return Version(string: versionString) ?? .one
    }
    
    public func fetchAppInfo() async throws -> App {
        var request = URLRequest(url: baseURL)
        request.httpMethod = "GET"
        
        do {
            let data = try await client.makeRequest(request)
            cache.set(data, forKey: "appInfoResponse")
            let appInfo = try parseResult(data).appList.iOS
            return appInfo
        } catch {
            return try loadFromDefaults()
        }
    }
    
    private func loadFromDefaults() throws -> App {
        guard let cachedResponse = cache.data(forKey: "appInfoResponse") else {
            throw AppInfoError.invalidResponse
        }
        
        let appInfo = try parseResult(cachedResponse).appList.iOS
        return appInfo
    }
    
    private func parseResult(_ dataArray: Data) throws -> AppInfoResponse {
        try JSONDecoder().decode(AppInfoResponse.self, from: dataArray)
    }
}
