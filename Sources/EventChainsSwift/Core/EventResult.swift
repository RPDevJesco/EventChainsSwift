/// Represents the outcome of an event execution
public struct EventResult {
    public let success: Bool
    public let error: String?
    
    private init(success: Bool, error: String?) {
        self.success = success
        self.error = error
    }
    
    /// Creates a successful result
    public static func success() -> EventResult {
        EventResult(success: true, error: nil)
    }
    
    /// Creates a failure result with an error message
    public static func failure(_ message: String) -> EventResult {
        EventResult(success: false, error: message)
    }
}
