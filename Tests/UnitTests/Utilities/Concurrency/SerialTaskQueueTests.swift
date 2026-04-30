import Foundation
@testable import OneLogin
import Testing

class ValueStore {
    var value: String
    
    init(value: String) {
        self.value = value
    }
}

class ValueService {
    enum ReusedValueError: Error, LocalizedError, CustomStringConvertible {
        case violation(_ value: String, _ values: Set<String>)
        
        var failureReason: String? {
            switch self {
            case let .violation(value, values):
                return "\(value.debugDescription) already exists in: \(values.debugDescription)"
            }
        }
        
        var description: String {
            switch self {
            case .violation:
                return "A value was used twice to update the unique set. This is a violation of the insert which expects a value to only be used once."
            }
        }
    }

    let lock = NSLock()
    var values = Set<String>()

    func use(_ value: String) async throws -> String {
        let inserted = lock.withLock {
            values.insert(value).inserted
        }
        
        guard inserted else {
            throw ReusedValueError.violation(value, values)
        }
        
        try await Task.sleep(nanoseconds: UInt64.random(in: 100_000_000...1_000_000_000)) //100ms to 1 second
        
        return UUID().uuidString
    }
}

final class ValueManager {
    
    let valueStore: ValueStore
    let valueService: ValueService
    
    init(valueStore: ValueStore, valueService: ValueService) {
        self.valueStore = valueStore
        self.valueService = valueService
    }
    
    public func update() async throws {
        let value = valueStore.value
        
        let newValue = try await valueService.use(value)

        valueStore.value = newValue
    }
}

class UnsafeCounter {
    var count: Int
    
    init(count: Int = 0) {
        self.count = count
    }
    
    func increment() async {
        var _count = self.count
        _count = _count + 1
        
        self.count = _count
    }
}

struct SerialTaskQueueTests {

    /// GIVEN a `SerialTaskQueue`
    /// WHEN an operation is enqueued
    /// AND succesfully finished with value
    /// THEN expect value
    @Test func enqueue_returns_value() async throws {
        let serialTaskQueue = SerialTaskQueue()
        
        let value = try await confirmation { confirmation in
            try await serialTaskQueue.enqueue {
                confirmation()
                return true
            }
        }
        
        #expect(value)
    }

    @Test func enqueue_void() async throws {
        let serialTaskQueue = SerialTaskQueue()
        
        try await confirmation { confirmation in
            try await serialTaskQueue.enqueue {
                confirmation()
            }
        }
    }
    
    /// GIVEN a `SerialTaskQueue`
    /// WHEN an operation is enqueued
    /// AND finished with an error
    /// THEN expect error
    @Test func enqueue_throws_error() async throws {
        let serialTaskQueue = SerialTaskQueue()
        let anyError = NSError(domain: "any", code: 1)

        await #expect(throws: (any Error).self) {
            try await confirmation { confirmation in
                try await serialTaskQueue.enqueue {
                    confirmation()
                    throw anyError
                }
            }
        }
    }
    
    /// GIVEN a `SerialTaskQueue`
    /// AND a `Counter` that is not a thread safe type
    /// WHEN enqueue an operation
    /// THEN will safely `incrementAndGet` the count to the number of tasks
    @Test func enqueue_eliminates_race_condition() async throws {
        let serialTaskQueue = SerialTaskQueue()
        let counter = UnsafeCounter(count: 0)

        let numberOfIncrements = 10
        await withTaskGroup { group in
            for _ in 1...numberOfIncrements {
                group.addTask {
                    try? await serialTaskQueue.enqueue {
                        await counter.increment()
                    }
                }
            }
        }
        
        #expect(counter.count == numberOfIncrements)
    }
        
    /// GIVEN a `SerialTaskQueue`
    /// WHEN an operation is enqued
    /// AND finished with an error
    /// THEN another operation CAN be enqued
    /// AND succesfully finish with value
    @Test func enqueue_twice_where_first_one_throws_error_continues_execution() async throws {
        let serialTaskQueue = SerialTaskQueue()
        let anyError = NSError(domain: "any", code: 1)
        
        await #expect(throws: (any Error).self) {
            try await confirmation { confirmation in
                try await serialTaskQueue.enqueue {
                    confirmation()
                    throw anyError
                }
            }
        }

        let value = try await confirmation { confirmation in
            try await serialTaskQueue.enqueue {
                confirmation()
                return true
            }
        }

        #expect(value)
    }
        
    ///
    /// A tests that asserts using a `SerialTaskQueue` to `enqueue` an update operation, guarantees a serial execution.
    ///
    /// This test re-creates the following scenario:
    ///     * Read a value
    ///     * Use the value
    ///     * Write the value
    ///
    /// This test requires a set of types to support the above scenario. Specifically:
    ///     * A type, to act as a store, where a value is read and written to. Namely, the `ValueStore`.
    ///     * A type, to act as a service, where the value is used. Namely, the `ValueService`.
    ///     * A type that performs the read/use/write sequence that should be protected by the `SerialQueue`. Namely, the `ValueManager`.
    ///
    /// Should the **same** value is used, *an error* will be recorded as an issue.
    ///
    /// This test creates a number of tasks that is "good enough" to generate the conditions to have an error thrown.
    ///
    /// GIVEN a number 'x'` of tasks
    /// WHEN performing 'x' number of updates
    /// ASSERT 'x' number of values are uniquely written
    ///
    /// - Remark: Calling `ValueManager/update()` in parallel, instead of enqueing it, will record an error:
    ///     `Caught error: A value was used twice to update the unique set. This is a violation of the insert which expects a value to only be used once.`
    ///
    @Test func enqueue_ensures_tasks_execute_in_sequence() async throws {
        let valueService = ValueService()
        let manager = ValueManager(valueStore: ValueStore(value: "any"), valueService: valueService)
        let serialTaskQueue = SerialTaskQueue()
        
        let numberOfTasks = 10
        await withTaskGroup { group in
            for _ in 1...numberOfTasks {
                group.addTask {
                    do {
                        try await serialTaskQueue.enqueue {
                            try await manager.update()
                        }
                    } catch {
                        Issue.record(error)
                    }
                }
            }
        }
        
        #expect(valueService.values.count == numberOfTasks)
    }
}
