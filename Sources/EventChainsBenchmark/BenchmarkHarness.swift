import Foundation

// MARK: - Benchmark Statistics

struct BenchmarkStats {
    let name: String
    let iterations: Int
    let totalTime: Double
    let avgTime: Double
    let minTime: Double
    let maxTime: Double
    let successCount: Int
    
    var opsPerSecond: Double {
        Double(iterations) / totalTime
    }
    
    func printResults() {
        print("\n\(name)")
        print(String(repeating: "-", count: 80))
        print(String(format: "Iterations:        %10d", iterations))
        print(String(format: "Total Time:        %10.6f seconds", totalTime))
        print(String(format: "Average Time:      %10.9f seconds (%10.6f μs)", avgTime, avgTime * 1_000_000))
        print(String(format: "Min Time:          %10.9f seconds (%10.6f μs)", minTime, minTime * 1_000_000))
        print(String(format: "Max Time:          %10.9f seconds (%10.6f μs)", maxTime, maxTime * 1_000_000))
        print(String(format: "Ops/Second:        %10.0f", opsPerSecond))
        print(String(format: "Success Rate:      %10d / %d (%.1f%%)", successCount, iterations, Double(successCount) / Double(iterations) * 100))
    }
    
    func overheadVs(_ baseline: BenchmarkStats) -> Double {
        ((avgTime - baseline.avgTime) / baseline.avgTime) * 100
    }
}

// MARK: - Benchmark Runner

struct BenchmarkRunner {
    static func run(
        name: String,
        iterations: Int,
        warmup: Int = 1000,
        work: () -> Bool
    ) -> BenchmarkStats {
        // Warmup phase
        for _ in 0..<warmup {
            _ = work()
        }
        
        // Measurement phase
        var times: [Double] = []
        var successCount = 0
        
        let overallStart = CFAbsoluteTimeGetCurrent()
        
        for _ in 0..<iterations {
            let start = CFAbsoluteTimeGetCurrent()
            let success = work()
            let end = CFAbsoluteTimeGetCurrent()
            
            times.append(end - start)
            if success {
                successCount += 1
            }
        }
        
        let overallEnd = CFAbsoluteTimeGetCurrent()
        let totalTime = overallEnd - overallStart
        
        let avgTime = times.reduce(0, +) / Double(times.count)
        let minTime = times.min() ?? 0
        let maxTime = times.max() ?? 0
        
        return BenchmarkStats(
            name: name,
            iterations: iterations,
            totalTime: totalTime,
            avgTime: avgTime,
            minTime: minTime,
            maxTime: maxTime,
            successCount: successCount
        )
    }
}

// MARK: - Comparison Utilities

struct BenchmarkComparison {
    static func printComparison(baseline: BenchmarkStats, others: [BenchmarkStats]) {
        print("\n" + String(repeating: "=", count: 80))
        print("PERFORMANCE COMPARISON")
        print(String(repeating: "=", count: 80))
        
        // Header
        let implCol = "Implementation".padding(toLength: 40, withPad: " ", startingAt: 0)
        let timeCol = "Avg Time (μs)".padding(toLength: 15, withPad: " ", startingAt: 0)
        let opsCol = "Ops/Sec".padding(toLength: 15, withPad: " ", startingAt: 0)
        let overheadCol = "Overhead"
        print("\n\(implCol) \(timeCol) \(opsCol) \(overheadCol)")
        print(String(repeating: "-", count: 80))
        
        // Baseline
        let baseName = baseline.name.padding(toLength: 40, withPad: " ", startingAt: 0)
        let baseTime = String(format: "%.6f", baseline.avgTime * 1_000_000).padding(toLength: 15, withPad: " ", startingAt: 0)
        let baseOps = String(format: "%.0f", baseline.opsPerSecond).padding(toLength: 15, withPad: " ", startingAt: 0)
        print("\(baseName) \(baseTime) \(baseOps) baseline")
        
        // Others
        for stats in others {
            let overhead = stats.overheadVs(baseline)
            let name = stats.name.padding(toLength: 40, withPad: " ", startingAt: 0)
            let time = String(format: "%.6f", stats.avgTime * 1_000_000).padding(toLength: 15, withPad: " ", startingAt: 0)
            let ops = String(format: "%.0f", stats.opsPerSecond).padding(toLength: 15, withPad: " ", startingAt: 0)
            let oh = String(format: "%.2f%%", overhead)
            print("\(name) \(time) \(ops) \(oh)")
        }
        
        print(String(repeating: "=", count: 80))
    }
    
    static func printScalingSummary(results: [(scale: Int, baseline: BenchmarkStats, eventChains: BenchmarkStats)]) {
        print("\n" + String(repeating: "=", count: 80))
        print("SCALING ANALYSIS")
        print(String(repeating: "=", count: 80))
        
        // Header
        let iterCol = "Iterations".padding(toLength: 15, withPad: " ", startingAt: 0)
        let baseCol = "Baseline (μs)".padding(toLength: 18, withPad: " ", startingAt: 0)
        let ecCol = "EventChains (μs)".padding(toLength: 18, withPad: " ", startingAt: 0)
        let ohCol = "Overhead %"
        print("\n\(iterCol) \(baseCol) \(ecCol) \(ohCol)")
        print(String(repeating: "-", count: 80))
        
        for result in results {
            let overhead = result.eventChains.overheadVs(result.baseline)
            let iter = String(result.scale).padding(toLength: 15, withPad: " ", startingAt: 0)
            let base = String(format: "%.6f", result.baseline.avgTime * 1_000_000).padding(toLength: 18, withPad: " ", startingAt: 0)
            let ec = String(format: "%.6f", result.eventChains.avgTime * 1_000_000).padding(toLength: 18, withPad: " ", startingAt: 0)
            let oh = String(format: "%.2f%%", overhead)
            print("\(iter) \(base) \(ec) \(oh)")
        }
        
        print(String(repeating: "=", count: 80))
        
        // Analyze if overhead decreases at scale
        if results.count >= 2 {
            let firstOverhead = results.first!.eventChains.overheadVs(results.first!.baseline)
            let lastOverhead = results.last!.eventChains.overheadVs(results.last!.baseline)
            let overheadChange = lastOverhead - firstOverhead
            
            print("\n📊 Scaling Behavior:")
            if overheadChange < -5 {
                print(String(format: "   ✅ Overhead DECREASES at scale (%.2f%% → %.2f%%)", firstOverhead, lastOverhead))
                print("   This suggests CPU optimizations (cache warming, branch prediction)")
            } else if overheadChange > 5 {
                print(String(format: "   ⚠️  Overhead INCREASES at scale (%.2f%% → %.2f%%)", firstOverhead, lastOverhead))
                print("   This suggests memory pressure or cache thrashing")
            } else {
                print(String(format: "   ➡️  Overhead remains CONSTANT at scale (%.2f%% → %.2f%%)", firstOverhead, lastOverhead))
                print("   This suggests consistent performance characteristics")
            }
        }
    }
}
