extension Array {
    func firstInstanceOf<T>(_ type: T.Type) -> T? {
        compactMap { $0 as? T }.first
    }
}
