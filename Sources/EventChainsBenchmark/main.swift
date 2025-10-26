import EventChainsSwift
import Foundation

print(String(repeating: "=", count: 80))
print("EventChains Swift - Multi-Tier Performance Benchmark Suite")
print(String(repeating: "=", count: 80))

let fixedScale = 100_000

// MARK: - Tier 1: Minimal Baseline vs EventChains

print("\n\n🎯 TIER 1: Cost of Orchestration Framework")
print(String(repeating: "=", count: 80))
print("Comparison: Bare function calls vs EventChains (0 middleware)")

let tier1Baseline = BenchmarkRunner.run(
    name: "Tier 1: Minimal Baseline (3 bare functions)",
    iterations: fixedScale
) {
    tier1Execute(value: 42) != nil
}
tier1Baseline.printResults()

let tier1Chain = EventChain()
    .addEvent(BenchmarkValidateEvent())
    .addEvent(BenchmarkTransformEvent())
    .addEvent(BenchmarkAccumulateEvent())

let tier1EC = BenchmarkRunner.run(
    name: "Tier 1: EventChains (0 middleware)",
    iterations: fixedScale
) {
    let context = EventContext()
    context.set("value", value: 42)
    return tier1Chain.execute(context).success
}
tier1EC.printResults()

BenchmarkComparison.printComparison(
    baseline: tier1Baseline,
    others: [tier1EC]
)

print("\n📊 Tier 1 Analysis:")
print(String(format: "   • Framework overhead: %.2f%%", tier1EC.overheadVs(tier1Baseline)))
print("   • This represents the minimal cost of the orchestration pattern")

// MARK: - Tier 2: Feature-Parity Baseline vs EventChains

print("\n\n🎯 TIER 2: Cost of Abstraction")
print(String(repeating: "=", count: 80))
print("Comparison: Hand-rolled error handling vs EventChains (0 middleware)")

let tier2Baseline = BenchmarkRunner.run(
    name: "Tier 2: Feature-Parity Baseline",
    iterations: fixedScale
) {
    switch tier2Execute(value: 42) {
    case .success: return true
    case .failure: return false
    }
}
tier2Baseline.printResults()

let tier2Chain = EventChain()
    .addEvent(BenchmarkValidateEvent())
    .addEvent(BenchmarkTransformEvent())
    .addEvent(BenchmarkAccumulateEvent())

let tier2EC = BenchmarkRunner.run(
    name: "Tier 2: EventChains (0 middleware)",
    iterations: fixedScale
) {
    let context = EventContext()
    context.set("value", value: 42)
    return tier2Chain.execute(context).success
}
tier2EC.printResults()

BenchmarkComparison.printComparison(
    baseline: tier2Baseline,
    others: [tier2EC]
)

print("\n📊 Tier 2 Analysis:")
print(String(format: "   • Abstraction overhead: %.2f%%", tier2EC.overheadVs(tier2Baseline)))
print("   • This compares EventChains to equivalent hand-rolled code")
print(String(format: "   • Baseline slowdown from Tier 1: %.2f%%", tier2Baseline.overheadVs(tier1Baseline)))

// MARK: - Tier 3: Middleware Scaling

print("\n\n🎯 TIER 3: Middleware Cost Per Layer")
print(String(repeating: "=", count: 80))

let middlewareCounts = [0, 1, 3, 5, 10]
var middlewareResults: [BenchmarkStats] = []

for count in middlewareCounts {
    var chain = EventChain()
        .addEvent(BenchmarkValidateEvent())
        .addEvent(BenchmarkTransformEvent())
        .addEvent(BenchmarkAccumulateEvent())
    
    for _ in 0..<count {
        chain = chain.useMiddleware(BenchmarkMinimalMiddleware())
    }
    
    let stats = BenchmarkRunner.run(
        name: "EventChains (\(count) middleware)",
        iterations: fixedScale
    ) {
        let context = EventContext()
        context.set("value", value: 42)
        return chain.execute(context).success
    }
    
    middlewareResults.append(stats)
    stats.printResults()
}

print("\n" + String(repeating: "=", count: 80))
print("MIDDLEWARE OVERHEAD ANALYSIS")
print(String(repeating: "=", count: 80))

let base = middlewareResults[0]

let nameCol = "Middleware Count".padding(toLength: 30, withPad: " ", startingAt: 0)
let timeCol = "Avg Time (μs)".padding(toLength: 20, withPad: " ", startingAt: 0)
let ohCol = "Overhead vs 0"
print("\n\(nameCol) \(timeCol) \(ohCol)")
print(String(repeating: "-", count: 80))

for stats in middlewareResults {
    let overhead = stats.overheadVs(base)
    let name = "\(stats.name)".padding(toLength: 30, withPad: " ", startingAt: 0)
    let time = String(format: "%.6f", stats.avgTime * 1_000_000).padding(toLength: 20, withPad: " ", startingAt: 0)
    let oh = String(format: "%.2f%%", overhead)
    print("\(name) \(time) \(oh)")
}

if middlewareResults.count >= 2 {
    let perLayerCost = (middlewareResults[1].avgTime - middlewareResults[0].avgTime) * 1_000_000
    print(String(format: "\n📊 Cost per middleware layer: ~%.6f μs", perLayerCost))
}

// MARK: - Tier 4: Real-World Scenario

print("\n\n🎯 TIER 4: Real-World Instrumentation")
print(String(repeating: "=", count: 80))
print("Comparison: Manual logging+timing vs EventChains with middleware")
print("\nNote: Output suppressed for performance measurement\n")

// Run Tier 4 baseline silently (suppress output)
let tier4Baseline = BenchmarkRunner.run(
    name: "Tier 4: Manual instrumentation",
    iterations: 1000  // Fewer iterations due to logging overhead
) {
    // Capture and discard output
    let originalStdout = dup(STDOUT_FILENO)
    let devNull = open("/dev/null", O_WRONLY)
    dup2(devNull, STDOUT_FILENO)
    close(devNull)
    
    let result = tier4Execute(value: 42)
    
    dup2(originalStdout, STDOUT_FILENO)
    close(originalStdout)
    
    switch result {
    case .success: return true
    case .failure: return false
    }
}
tier4Baseline.printResults()

// EventChains with logging + timing middleware
let tier4Chain = EventChain()
    .addEvent(BenchmarkValidateEvent())
    .addEvent(BenchmarkTransformEvent())
    .addEvent(BenchmarkAccumulateEvent())
    .useMiddleware(LoggingMiddleware())
    .useMiddleware(TimingMiddleware())

let tier4EC = BenchmarkRunner.run(
    name: "Tier 4: EventChains (logging+timing)",
    iterations: 1000
) {
    // Capture and discard output
    let originalStdout = dup(STDOUT_FILENO)
    let devNull = open("/dev/null", O_WRONLY)
    dup2(devNull, STDOUT_FILENO)
    close(devNull)
    
    let context = EventContext()
    context.set("value", value: 42)
    let result = tier4Chain.execute(context).success
    
    dup2(originalStdout, STDOUT_FILENO)
    close(originalStdout)
    
    return result
}
tier4EC.printResults()

BenchmarkComparison.printComparison(
    baseline: tier4Baseline,
    others: [tier4EC]
)

print("\n📊 Tier 4 Analysis:")
print(String(format: "   • Real-world overhead: %.2f%%", tier4EC.overheadVs(tier4Baseline)))
print("   • This shows the cost when using common middleware features")

// MARK: - Scaling Analysis

print("\n\n🎯 SCALING ANALYSIS: Overhead Behavior Across Iteration Counts")
print(String(repeating: "=", count: 80))

let scales = [100, 1_000, 10_000, 100_000, 1_000_000]
var scalingResults: [(scale: Int, baseline: BenchmarkStats, eventChains: BenchmarkStats)] = []

for scale in scales {
    print("\n📊 Testing at \(scale) iterations...")
    
    let baselineScaling = BenchmarkRunner.run(
        name: "Baseline",
        iterations: scale,
        warmup: min(1000, scale / 10)
    ) {
        tier1Execute(value: 42) != nil
    }
    
    let chainScaling = EventChain()
        .addEvent(BenchmarkValidateEvent())
        .addEvent(BenchmarkTransformEvent())
        .addEvent(BenchmarkAccumulateEvent())
    
    let ecScaling = BenchmarkRunner.run(
        name: "EventChains",
        iterations: scale,
        warmup: min(1000, scale / 10)
    ) {
        let context = EventContext()
        context.set("value", value: 42)
        return chainScaling.execute(context).success
    }
    
    scalingResults.append((scale: scale, baseline: baselineScaling, eventChains: ecScaling))
    
    print(String(format: "   Baseline:     %.6f μs/op", baselineScaling.avgTime * 1_000_000))
    print(String(format: "   EventChains:  %.6f μs/op", ecScaling.avgTime * 1_000_000))
    print(String(format: "   Overhead:     %.2f%%", ecScaling.overheadVs(baselineScaling)))
}

BenchmarkComparison.printScalingSummary(results: scalingResults)

// MARK: - Comprehensive Summary

print("\n\n" + String(repeating: "=", count: 80))
print("COMPREHENSIVE BENCHMARK SUMMARY")
print(String(repeating: "=", count: 80))

print("\n📊 Overhead Breakdown by Tier:")
print(String(repeating: "-", count: 80))
print(String(format: "   Tier 1 (Orchestration):     %.2f%%", tier1EC.overheadVs(tier1Baseline)))
print(String(format: "   Tier 2 (Abstraction):       %.2f%%", tier2EC.overheadVs(tier2Baseline)))
if middlewareResults.count >= 2 {
    let perLayerCost = (middlewareResults[1].avgTime - middlewareResults[0].avgTime) * 1_000_000
    print(String(format: "   Tier 3 (Per middleware):    ~%.6f μs/layer", perLayerCost))
}
print(String(format: "   Tier 4 (Real-world):        %.2f%%", tier4EC.overheadVs(tier4Baseline)))

print("\n📊 Key Insights:")
let tier1Overhead = tier1EC.overheadVs(tier1Baseline)
if tier1Overhead < 50 {
    print("   ✅ Core framework overhead is excellent (<50%)")
} else if tier1Overhead < 100 {
    print("   ✓ Core framework overhead is acceptable (50-100%)")
} else {
    print("   ⚠️  Core framework overhead is high (>100%)")
}

let tier2Overhead = tier2EC.overheadVs(tier2Baseline)
if tier2Overhead < 25 {
    print("   ✅ Abstraction cost is minimal compared to hand-rolled code")
} else if tier2Overhead < 50 {
    print("   ✓ Abstraction cost is reasonable compared to hand-rolled code")
} else {
    print("   ⚠️  Abstraction cost is significant compared to hand-rolled code")
}

if let firstScale = scalingResults.first, let lastScale = scalingResults.last {
    let overheadChange = lastScale.eventChains.overheadVs(lastScale.baseline) -
                        firstScale.eventChains.overheadVs(firstScale.baseline)
    if overheadChange < -5 {
        print("   ✅ Overhead DECREASES at scale (CPU optimizations working)")
    } else if overheadChange.magnitude < 5 {
        print("   ✓ Overhead remains CONSTANT at scale (consistent performance)")
    } else {
        print("   ⚠️  Overhead INCREASES at scale (potential memory pressure)")
    }
}

print("\n" + String(repeating: "=", count: 80))
print("Benchmark Complete!")
print(String(repeating: "=", count: 80))
