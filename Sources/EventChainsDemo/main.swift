import EventChainsSwift
import Foundation

print(String(repeating: "=", count: 60))
print("EventChains Swift - Demo")
print(String(repeating: "=", count: 60))

// MARK: - Test 1: Basic Chain Execution

print("\n📋 Test 1: Basic Chain (Strict Mode)")
print(String(repeating: "-", count: 60))

let basicChain = EventChain(faultTolerance: .strict)
    .addEvent(ValidateInputEvent())
    .addEvent(ProcessDataEvent())
    .addEvent(SaveResultEvent())

let context1 = EventContext()
context1.set("input", value: 21)

let result1 = basicChain.execute(context1)
print("\nResult: \(result1.success ? "✓ Success" : "✗ Failed")")
if let error = result1.error {
    print("Error: \(error)")
}

// MARK: - Test 2: Chain with Middleware

print("\n\n📋 Test 2: Chain with Middleware")
print(String(repeating: "-", count: 60))

let middlewareChain = EventChain(faultTolerance: .strict)
    .addEvent(ValidateInputEvent())
    .addEvent(ProcessDataEvent())
    .addEvent(SaveResultEvent())
    .useMiddleware(LoggingMiddleware())
    .useMiddleware(TimingMiddleware())

let context2 = EventContext()
context2.set("input", value: 42)

let result2 = middlewareChain.execute(context2)
print("\nResult: \(result2.success ? "✓ Success" : "✗ Failed")")

// MARK: - Test 3: Failure Handling

print("\n\n📋 Test 3: Failure Handling (Negative Input)")
print(String(repeating: "-", count: 60))

let context3 = EventContext()
context3.set("input", value: -10)

let result3 = middlewareChain.execute(context3)
print("\nResult: \(result3.success ? "✓ Success" : "✗ Failed")")
if let error = result3.error {
    print("Error: \(error)")
}

// MARK: - Test 4: Lenient Mode

print("\n\n📋 Test 4: Lenient Mode (Continues on Failure)")
print(String(repeating: "-", count: 60))

let lenientChain = EventChain(faultTolerance: .lenient)
    .addEvent(ValidateInputEvent())
    .addEvent(ProcessDataEvent())
    .addEvent(SaveResultEvent())
    .useMiddleware(LoggingMiddleware())

let context4 = EventContext()
context4.set("input", value: -5)

let result4 = lenientChain.execute(context4)
print("\nResult: \(result4.success ? "✓ Success" : "✗ Failed")")
if let error = result4.error {
    print("Error: \(error)")
}

// MARK: - Test 5: Pipeline Caching Performance

print("\n\n📋 Test 5: Pipeline Caching (Performance)")
print(String(repeating: "-", count: 60))

let perfChain = EventChain()
    .addEvent(ValidateInputEvent())
    .addEvent(ProcessDataEvent())

let iterations = 10_000
let start = CFAbsoluteTimeGetCurrent()

for i in 0..<iterations {
    let ctx = EventContext()
    ctx.set("input", value: i)
    _ = perfChain.execute(ctx)
}

let duration = CFAbsoluteTimeGetCurrent() - start
print("Executed \(iterations) iterations in \(String(format: "%.6f", duration))s")
print("Average: \(String(format: "%.9f", duration / Double(iterations)))s per execution")

print("\n" + String(repeating: "=", count: 60))
print("Demo Complete!")
print(String(repeating: "=", count: 60))
