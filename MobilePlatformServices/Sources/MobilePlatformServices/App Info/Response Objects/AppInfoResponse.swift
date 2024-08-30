import Foundation

struct AppInfoResponse: Decodable {
    let appList: Apps

    enum CodingKeys: String, CodingKey {
        case appList = "apps"
    }
}

struct Apps: Decodable {
    let iOS: App
}
