/// Protocol for middleware that wraps event execution
public protocol Middleware {
    /// Executes middleware logic, optionally calling the next handler
    /// - Parameters:
    ///   - context: Shared context
    ///   - next: Next handler in the pipeline
    /// - Returns: Result of execution
    func execute(_ context: EventContext, next: @escaping (EventContext) -> EventResult) -> EventResult
}
