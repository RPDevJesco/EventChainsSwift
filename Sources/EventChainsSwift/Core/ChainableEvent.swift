/// Protocol for events that can be executed in a chain
public protocol ChainableEvent {
    /// Executes the event logic
    /// - Parameter context: Shared context for data exchange
    /// - Returns: Result indicating success or failure
    func execute(_ context: EventContext) -> EventResult
}

/// Default implementation for event name (used in logging/debugging)
public extension ChainableEvent {
    var name: String {
        String(describing: type(of: self))
    }
}
