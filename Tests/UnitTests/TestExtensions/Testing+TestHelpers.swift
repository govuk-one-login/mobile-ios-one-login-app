import Testing

/// Usage:
/// #expect(await eventually { <what we need to be true after some timne> })
func eventually(timeout: Duration = .seconds(2),
                interval: Duration = .milliseconds(20),
                _ condition: @escaping () -> Bool) async -> Bool {
    let deadline = ContinuousClock.now + timeout
    while ContinuousClock.now < deadline {
        if condition() { return true }
        try? await Task.sleep(for: interval)
    }
    return false
}
