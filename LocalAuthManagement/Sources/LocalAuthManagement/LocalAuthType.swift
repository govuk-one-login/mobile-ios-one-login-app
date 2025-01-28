public protocol LocalAuthType: RawRepresentable where RawValue == Int {
    static var none: Self { get }
    static var passcodeOnly: Self { get }
    static var touchID: Self { get }
    static var faceID: Self { get }
}
