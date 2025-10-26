import EventChainsSwift
import Foundation

// MARK: - Benchmark Events

/// Simple validation event for benchmarking
struct BenchmarkValidateEvent: ChainableEvent {
    func execute(_ context: EventContext) -> EventResult {
        guard let value: Int = context.get("value") else {
            return EventResult.failure("Missing value")
        }
        
        if value < 0 {
            return EventResult.failure("Value must be positive")
        }
        
        return EventResult.success()
    }
}

/// Simple transformation event for benchmarking
struct BenchmarkTransformEvent: ChainableEvent {
    func execute(_ context: EventContext) -> EventResult {
        guard let value: Int = context.get("value") else {
            return EventResult.failure("Missing value")
        }
        
        context.set("result", value: value * 2)
        return EventResult.success()
    }
}

/// Simple accumulation event for benchmarking
struct BenchmarkAccumulateEvent: ChainableEvent {
    func execute(_ context: EventContext) -> EventResult {
        guard let result: Int = context.get("result") else {
            return EventResult.failure("Missing result")
        }
        
        let current: Int = context.get("accumulator") ?? 0
        context.set("accumulator", value: current + result)
        return EventResult.success()
    }
}

// MARK: - Benchmark Middleware

/// Minimal middleware that does almost nothing (for overhead measurement)
struct BenchmarkMinimalMiddleware: Middleware {
    func execute(_ context: EventContext, next: @escaping (EventContext) -> EventResult) -> EventResult {
        return next(context)
    }
}

/// Middleware that increments a counter (to prevent optimization removal)
struct BenchmarkCounterMiddleware: Middleware {
    func execute(_ context: EventContext, next: @escaping (EventContext) -> EventResult) -> EventResult {
        let count: Int = context.get("_middleware_calls") ?? 0
        context.set("_middleware_calls", value: count + 1)
        return next(context)
    }
}

/// Middleware that does a tiny amount of work (simulates real middleware)
struct BenchmarkWorkMiddleware: Middleware {
    func execute(_ context: EventContext, next: @escaping (EventContext) -> EventResult) -> EventResult {
        // Simulate minimal work (check a condition)
        let _: Int? = context.get("value")
        return next(context)
    }
}
