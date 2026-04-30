/// A FIFO queue that guarantees a serialised execution of `async` operations.
///
/// An operation is a closure that contains the work for the queue to perform.
///
/// Unlike a `TaskExecutor` (i.e. a `DispatchSerialQueue`), this queue ensures that:
/// * Only one operation is executed at any time.
/// * Operations are executed in a FIFO order.
/// * An operation will **only** start running once the last one one has finished executing.
///
///  | order |n|2|1 |
/// :---------:|:-------|:---------:|:---------:|
/// **enqueue**|operation (n) |operation (2) | operation (1)
/// **finish**|*success* |*failure* | *success*
/// *<---time* ||||
///
/// An operation is considered to have finish execution either succesfully by returning a result or with a failure by
/// throwing an error. Either way, any operation that follows will start running immediately after.
///
/// Once an operation has been enqueued, it cannot be cancelled.
///
/// A `SerialTaskQueue` can be used to eliminate race conditions that may arise from `async` functions
/// that are otherwise not thread safe.
///
/// Take the following example of a non thread safe type:
///
/// ```
/// class UnsafeCounter {
///     var count: Int
///
///     init(count: Int = 0) {
///         self.count = count
///     }
///
///     func increment() async {
///         var _count = self.count
///         _count = _count + 1
///
///         self.count = _count
///
///         return self.count
///     }
/// }
/// ```
/// You can enqueue the `increment` operation to safely increment the counter across multiple tasks. 
///
/// ```
/// let serialTaskQueue = SerialTaskQueue()
/// let counter = UnsafeCounter(count: 0)
///
/// let numberOfIncrements = 10
/// await withTaskGroup { group in
///     for _ in 1...numberOfIncrements {
///         group.addTask {
///                 try? await serialTaskQueue.enqueue {
///                     return await counter.increment()
///                 }
///             }
///         }
///     }
/// ```
///
///
/// - Note: The `queue` is unbounded, meaning it can never be full and never blocks enqueing an operation.
final actor SerialTaskQueue {
    
    typealias Operation<Success> = () async throws -> Success
    private var currentTask: Task<Void, Never>?
    
    /// Schedule an `async` operation to start running.
    ///
    /// A subsequent call to`enqueue(_:)` will wait starting the operation until the last one to be enqueued has finished executing either succesfuly or with a result value.
    ///
    /// - parameter operation: the operation to perfom
    func enqueue<Success>(_ operation: sending @escaping Operation<Success>) async throws -> Success {
        try await withCheckedThrowingContinuation { continuation in
            let newTask = Task { [lastTask = currentTask] in
                do {
                    await lastTask?.value
                    
                    let value = try await operation()
                    continuation.resume(returning: value)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
            
            self.currentTask = newTask
        }
    }
}
