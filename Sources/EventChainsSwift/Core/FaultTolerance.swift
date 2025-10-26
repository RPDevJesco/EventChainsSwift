/// Defines how the chain handles event failures
public enum FaultTolerance {
    /// Stop immediately on first failure
    case strict
    
    /// Log failures but continue execution
    case lenient
    
    /// Try all events regardless of failures
    case bestEffort
}
