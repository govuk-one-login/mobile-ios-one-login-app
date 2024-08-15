import Foundation
import Networking
import UIKit

public protocol AppInformationServicing {
    func fetchAppInfo() async throws -> App
    var currentVersion: Version { get }
}

public final class AppInformationService: AppInformationServicing {
    private let client: NetworkClient
    
    /// Initialise a new `AppInformationService`
    ///
    /// No parameters are required.
    public convenience init() {
        self.init(client: .init())
    }
    
    init(client: NetworkClient) {
        self.client = client
    }
    
    public var currentVersion: Version {
        guard let versionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else { return .one }
        return Version(string: versionString) ?? .one
    }
    
    public func fetchAppInfo() async throws -> App {
        let updateURL = Service.baseURL!.appendingPathComponent("appInfo")
        var request = URLRequest(url: updateURL)
        request.httpMethod = "GET"
        
        let data = try await client.makeRequest(request)
        let appInfo = try parseResult(data).appList.iOS
        
        return appInfo
    }
    
    private func parseResult(_ dataArray: Data) throws -> AppInfoResponse {
        try JSONDecoder().decode(AppInfoResponse.self, from: dataArray)
    }
}
