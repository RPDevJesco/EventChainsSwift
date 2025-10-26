# EventChains Swift

A Swift implementation of the EventChains design pattern for building observable, composable sequential workflows.

## Features

- ✅ Type-safe context with generics
- ✅ Pipeline caching for performance
- ✅ LIFO middleware execution
- ✅ Multiple fault tolerance modes
- ✅ Protocol-oriented design

## Quick Start

```swift
import EventChainsSwift

let chain = EventChain()
    .addEvent(ValidateInputEvent())
    .addEvent(ProcessDataEvent())
    .useMiddleware(LoggingMiddleware())

let context = EventContext()
context.set("input", value: 42)

let result = chain.execute(context)
```

## Building

```bash
swift build
swift run EventChainsDemo
swift test
```

## Performance Characteristics

- **EventContext**: Class-based (reference semantics) to avoid copy overhead
- **Type Safety**: Generic get/set with ~15-25% overhead
- **Protocol Dispatch**: ~10-15% overhead vs direct calls
- **Pipeline Caching**: Built once, reused across executions

Expected overhead: 40-65% vs raw function calls, with scaling advantages at high iteration counts.

## Project Structure

```
EventChainsSwift/
├── Package.swift
├── Sources/
│   ├── EventChainsSwift/
│   │   ├── Core/
│   │   │   ├── EventResult.swift
│   │   │   ├── EventContext.swift
│   │   │   ├── ChainableEvent.swift
│   │   │   ├── Middleware.swift
│   │   │   ├── FaultTolerance.swift
│   │   │   └── EventChain.swift
│   │   └── Examples/
│   │       ├── SimpleEvents.swift
│   │       └── SimpleMiddleware.swift
│   └── EventChainsDemo/
│       └── main.swift
└── Tests/
    └── EventChainsSwiftTests/
        └── EventChainTests.swift
```

## Core Concepts

### EventContext
A shared data container that flows through the entire chain, enabling communication between sequential events.

### ChainableEvent
A discrete unit of business logic that receives context, can read/modify it, and returns a Result.

### Middleware
Wraps event execution with cross-cutting concerns (logging, timing, validation). Executes in LIFO order.

### EventChain
Orchestrates the sequential flow, manages middleware pipeline construction, and handles error propagation.

## License

MIT License
