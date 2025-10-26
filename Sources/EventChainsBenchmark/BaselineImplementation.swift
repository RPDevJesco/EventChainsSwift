import Foundation

// MARK: - Shared Baseline Context

/// Simple storage for baseline implementations
final class BaselineContext {
    private var storage: [String: Any] = [:]
    
    func get<T>(_ key: String) -> T? {
        storage[key] as? T
    }
    
    func set<T>(_ key: String, value: T) {
        storage[key] = value
    }
    
    func clear() {
        storage.removeAll()
    }
}

// MARK: - Tier 1: Minimal Baseline (Bare Function Calls)

/// Minimal validation - no error messages, just bool
func tier1Validate(context: BaselineContext) -> Bool {
    guard let value: Int = context.get("value") else {
        return false
    }
    return value >= 0
}

/// Minimal transformation - no error handling
func tier1Transform(context: BaselineContext) -> Bool {
    guard let value: Int = context.get("value") else {
        return false
    }
    context.set("result", value: value * 2)
    return true
}

/// Minimal accumulation
func tier1Accumulate(context: BaselineContext) -> Bool {
    guard let result: Int = context.get("result") else {
        return false
    }
    let current: Int = context.get("accumulator") ?? 0
    context.set("accumulator", value: current + result)
    return true
}

/// Execute tier 1 workflow - minimal overhead
func tier1Execute(value: Int) -> Int? {
    let context = BaselineContext()
    context.set("value", value: value)
    
    guard tier1Validate(context: context),
          tier1Transform(context: context),
          tier1Accumulate(context: context) else {
        return nil
    }
    
    return context.get("accumulator")
}

// MARK: - Tier 2: Feature-Parity Baseline (With Error Handling & Tracking)

struct BaselineError: Error {
    let message: String
    let eventName: String
}

struct StringError: Error {
    let message: String
}

/// Validation with error messages and name tracking
func tier2Validate(context: BaselineContext, eventName: inout String) -> Result<Void, BaselineError> {
    eventName = "ValidateEvent"
    
    guard let value: Int = context.get("value") else {
        return .failure(BaselineError(message: "Missing value", eventName: eventName))
    }
    
    if value < 0 {
        return .failure(BaselineError(message: "Value must be positive", eventName: eventName))
    }
    
    return .success(())
}

/// Transformation with error messages
func tier2Transform(context: BaselineContext, eventName: inout String) -> Result<Void, BaselineError> {
    eventName = "TransformEvent"
    
    guard let value: Int = context.get("value") else {
        return .failure(BaselineError(message: "Missing value", eventName: eventName))
    }
    
    context.set("result", value: value * 2)
    return .success(())
}

/// Accumulation with error messages
func tier2Accumulate(context: BaselineContext, eventName: inout String) -> Result<Void, BaselineError> {
    eventName = "AccumulateEvent"
    
    guard let result: Int = context.get("result") else {
        return .failure(BaselineError(message: "Missing result", eventName: eventName))
    }
    
    let current: Int = context.get("accumulator") ?? 0
    context.set("accumulator", value: current + result)
    return .success(())
}

/// Execute tier 2 workflow - with error handling and cleanup
func tier2Execute(value: Int) -> Result<Int, StringError> {
    let context = BaselineContext()
    context.set("value", value: value)
    
    var eventName = ""
    
    // Execute with error tracking
    switch tier2Validate(context: context, eventName: &eventName) {
    case .success: break
    case .failure(let error):
        context.clear()
        return .failure(StringError(message: "\(error.eventName): \(error.message)"))
    }
    
    switch tier2Transform(context: context, eventName: &eventName) {
    case .success: break
    case .failure(let error):
        context.clear()
        return .failure(StringError(message: "\(error.eventName): \(error.message)"))
    }
    
    switch tier2Accumulate(context: context, eventName: &eventName) {
    case .success: break
    case .failure(let error):
        context.clear()
        return .failure(StringError(message: "\(error.eventName): \(error.message)"))
    }
    
    guard let result: Int = context.get("accumulator") else {
        context.clear()
        return .failure(StringError(message: "Missing final result"))
    }
    
    context.clear()
    return .success(result)
}

// MARK: - Tier 4: Real-World Scenario (Manual Instrumentation)

/// Execute tier 4 workflow - with logging and timing
func tier4Execute(value: Int) -> Result<Int, StringError> {
    let context = BaselineContext()
    context.set("value", value: value)
    
    var eventName = ""
    var totalDuration: Double = 0
    
    // Validate with logging and timing
    eventName = "ValidateEvent"
    print("→ Starting: \(eventName)")
    var start = CFAbsoluteTimeGetCurrent()
    
    let validateResult = tier2Validate(context: context, eventName: &eventName)
    
    var duration = CFAbsoluteTimeGetCurrent() - start
    totalDuration += duration
    print("⏱ \(eventName): \(String(format: "%.6f", duration))s")
    
    switch validateResult {
    case .success:
        print("✓ Completed: \(eventName)")
    case .failure(let error):
        print("✗ Failed: \(eventName) - \(error.message)")
        context.clear()
        return .failure(StringError(message: "\(error.eventName): \(error.message)"))
    }
    
    // Transform with logging and timing
    eventName = "TransformEvent"
    print("→ Starting: \(eventName)")
    start = CFAbsoluteTimeGetCurrent()
    
    let transformResult = tier2Transform(context: context, eventName: &eventName)
    
    duration = CFAbsoluteTimeGetCurrent() - start
    totalDuration += duration
    print("⏱ \(eventName): \(String(format: "%.6f", duration))s")
    
    switch transformResult {
    case .success:
        print("✓ Completed: \(eventName)")
    case .failure(let error):
        print("✗ Failed: \(eventName) - \(error.message)")
        context.clear()
        return .failure(StringError(message: "\(error.eventName): \(error.message)"))
    }
    
    // Accumulate with logging and timing
    eventName = "AccumulateEvent"
    print("→ Starting: \(eventName)")
    start = CFAbsoluteTimeGetCurrent()
    
    let accumulateResult = tier2Accumulate(context: context, eventName: &eventName)
    
    duration = CFAbsoluteTimeGetCurrent() - start
    totalDuration += duration
    print("⏱ \(eventName): \(String(format: "%.6f", duration))s")
    
    switch accumulateResult {
    case .success:
        print("✓ Completed: \(eventName)")
    case .failure(let error):
        print("✗ Failed: \(eventName) - \(error.message)")
        context.clear()
        return .failure(StringError(message: "\(error.eventName): \(error.message)"))
    }
    
    guard let result: Int = context.get("accumulator") else {
        context.clear()
        return .failure(StringError(message: "Missing final result"))
    }
    
    context.clear()
    return .success(result)
}

// MARK: - Legacy Alias (for backward compatibility)

/// Execute baseline workflow (uses tier 1)
func baselineExecute(value: Int) -> Int? {
    tier1Execute(value: value)
}
