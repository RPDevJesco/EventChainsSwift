import XCTest
@testable import EventChainsSwift

final class EventChainTests: XCTestCase {
    
    func testBasicExecution() {
        let chain = EventChain()
            .addEvent(ValidateInputEvent())
            .addEvent(ProcessDataEvent())
        
        let context = EventContext()
        context.set("input", value: 21)
        
        let result = chain.execute(context)
        
        XCTAssertTrue(result.success)
    }
    
    func testFailureHandling() {
        let chain = EventChain(faultTolerance: .strict)
            .addEvent(ValidateInputEvent())
        
        let context = EventContext()
        context.set("input", value: -10)
        
        let result = chain.execute(context)
        
        XCTAssertFalse(result.success)
        XCTAssertNotNil(result.error)
    }
    
    func testMiddlewareExecution() {
        let chain = EventChain()
            .addEvent(ProcessDataEvent())
            .useMiddleware(LoggingMiddleware())
        
        let context = EventContext()
        context.set("input", value: 5)
        
        let result = chain.execute(context)
        
        XCTAssertTrue(result.success)
        let output: Int? = context.get("output")
        XCTAssertNil(output) // Context cleared after execution
    }
    
    func testContextClearing() {
        let chain = EventChain()
            .addEvent(ProcessDataEvent())
        
        let context = EventContext()
        context.set("input", value: 10)
        
        _ = chain.execute(context)
        
        let input: Int? = context.get("input")
        XCTAssertNil(input, "Context should be cleared after execution")
    }
}
