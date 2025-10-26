import Foundation

/// Validates that input is positive
public struct ValidateInputEvent: ChainableEvent {
    public init() {}
    
    public func execute(_ context: EventContext) -> EventResult {
        guard let value: Int = context.get("input") else {
            return EventResult.failure("Missing input value")
        }
        
        if value < 0 {
            return EventResult.failure("Input must be positive")
        }
        
        return EventResult.success()
    }
}

/// Doubles the input value
public struct ProcessDataEvent: ChainableEvent {
    public init() {}
    
    public func execute(_ context: EventContext) -> EventResult {
        guard let value: Int = context.get("input") else {
            return EventResult.failure("Missing input value")
        }
        
        context.set("output", value: value * 2)
        return EventResult.success()
    }
}

/// Saves the result (simulated)
public struct SaveResultEvent: ChainableEvent {
    public init() {}
    
    public func execute(_ context: EventContext) -> EventResult {
        guard let output: Int = context.get("output") else {
            return EventResult.failure("Missing output value")
        }
        
        print("Saving result: \(output)")
        context.set("saved", value: true)
        return EventResult.success()
    }
}
