/// Shared data container that flows through the event chain
/// Uses reference semantics to avoid expensive copies
public final class EventContext {
    private var storage: [String: Any] = [:]
    
    public init() {}
    
    /// Retrieves a value from the context with type safety
    public func get<T>(_ key: String) -> T? {
        storage[key] as? T
    }
    
    /// Stores a value in the context
    public func set<T>(_ key: String, value: T) {
        storage[key] = value
    }
    
    /// Checks if a key exists in the context
    public func has(_ key: String) -> Bool {
        storage[key] != nil
    }
    
    /// Clears all data from the context
    public func clear() {
        storage.removeAll()
    }
    
    /// Returns the number of items in the context
    public var count: Int {
        storage.count
    }
}
