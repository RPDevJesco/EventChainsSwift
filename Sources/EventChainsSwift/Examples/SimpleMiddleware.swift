import Foundation

/// Logs event execution
public struct LoggingMiddleware: Middleware {
    public init() {}
    
    public func execute(_ context: EventContext, next: @escaping (EventContext) -> EventResult) -> EventResult {
        let eventName: String = context.get("_current_event") ?? "Unknown"
        print("→ Starting: \(eventName)")
        
        let result = next(context)
        
        if result.success {
            print("✓ Completed: \(eventName)")
        } else {
            print("✗ Failed: \(eventName) - \(result.error ?? "Unknown error")")
        }
        
        return result
    }
}

/// Times event execution
public struct TimingMiddleware: Middleware {
    public init() {}
    
    public func execute(_ context: EventContext, next: @escaping (EventContext) -> EventResult) -> EventResult {
        let eventName: String = context.get("_current_event") ?? "Unknown"
        let start = CFAbsoluteTimeGetCurrent()
        
        let result = next(context)
        
        let duration = CFAbsoluteTimeGetCurrent() - start
        print("⏱ \(eventName): \(String(format: "%.6f", duration))s")
        
        return result
    }
}
