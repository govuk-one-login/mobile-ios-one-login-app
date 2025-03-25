import Foundation

extension Dictionary where Key == String, Value == Any {
    static let oneLoginDefaults = [
        "saved_doc_type": "undefined",
        "primary_publishing_organisation": "government digital service - digital identity",
        "organisation": "<OT1056>",
        "taxonomy_level1": "one login mobile application",
        "language": "\(NSLocale.current.identifier.prefix(2))"
    ]
}
