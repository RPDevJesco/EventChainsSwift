/// Orchestrates sequential execution of events with middleware
public final class EventChain {
    private var events: [ChainableEvent] = []
    private var middleware: [Middleware] = []
    private var faultTolerance: FaultTolerance = .strict
    private var cachedPipeline: ((EventContext) -> EventResult)?
    
    // MARK: - Initialization
    
    public init(faultTolerance: FaultTolerance = .strict) {
        self.faultTolerance = faultTolerance
    }
    
    // MARK: - Builder Methods
    
    @discardableResult
    public func addEvent(_ event: ChainableEvent) -> EventChain {
        events.append(event)
        cachedPipeline = nil
        return self
    }
    
    @discardableResult
    public func useMiddleware(_ middleware: Middleware) -> EventChain {
        self.middleware.append(middleware)
        cachedPipeline = nil
        return self
    }
    
    @discardableResult
    public func setFaultTolerance(_ tolerance: FaultTolerance) -> EventChain {
        self.faultTolerance = tolerance
        cachedPipeline = nil
        return self
    }
    
    // MARK: - Execution
    
    public func execute(_ context: EventContext) -> EventResult {
        if cachedPipeline == nil {
            cachedPipeline = buildPipeline()
        }
        
        guard let pipeline = cachedPipeline else {
            return EventResult.failure("Failed to build execution pipeline")
        }
        
        let result = pipeline(context)
        context.clear()
        return result
    }
    
    // MARK: - Pipeline Construction
    
    private func buildPipeline() -> (EventContext) -> EventResult {
        // Don't wrap the entire executor - wrap each individual event
        let coreExecution = buildEventExecutor()
        return coreExecution
    }
    
    private func buildEventExecutor() -> (EventContext) -> EventResult {
        // Create wrapped version of each event with its middleware
        let wrappedEvents: [(name: String, executor: (EventContext) -> EventResult)] = events.map { event in
            let eventName = String(describing: type(of: event))
            
            // Core event execution (without setting name - that happens outside)
            let eventExecutor: (EventContext) -> EventResult = { context in
                return event.execute(context)
            }
            
            // Wrap with middleware in LIFO order
            let wrapped = middleware.reversed().reduce(eventExecutor) { next, mw in
                return { context in
                    mw.execute(context, next: next)
                }
            }
            
            return (name: eventName, executor: wrapped)
        }
        
        return { [weak self] context in
            guard let self = self else {
                return EventResult.failure("EventChain deallocated during execution")
            }
            
            var failures: [String] = []
            
            for wrappedEvent in wrappedEvents {
                // Set event name BEFORE calling middleware
                context.set("_current_event", value: wrappedEvent.name)
                
                let result = wrappedEvent.executor(context)
                
                if !result.success {
                    failures.append(result.error ?? "Unknown error in \(wrappedEvent.name)")
                    
                    switch self.faultTolerance {
                    case .strict:
                        return EventResult.failure(failures.joined(separator: "; "))
                    case .lenient, .bestEffort:
                        continue
                    }
                }
            }
            
            context.set("_current_event", value: nil as String?)
            
            if !failures.isEmpty {
                return EventResult.failure("Completed with errors: \(failures.joined(separator: "; "))")
            }
            
            return EventResult.success()
        }
    }
}
