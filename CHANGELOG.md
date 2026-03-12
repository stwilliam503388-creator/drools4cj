# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2026-03-12

### Added
- `cjpm.toml` package manifest for standard Cangjie package management
- Abstract `toString()` method in `Fact` base class for polymorphic fact printing
- `CHANGELOG.md` to track version history per Cangjie third-party library standards

### Fixed
- `WorkingMemory.cj`: Fixed `?.append()` to use proper `if (let factList = ...) { factList.add() }` idiom
- `WorkingMemory.cj`: Fixed `getFact()` to correctly return `None` when the fact ID is not found
- `WorkingMemory.cj`: Fixed `getVersion()` to correctly return `None` when the fact ID is not found
- `WorkingMemory.cj`: Replaced type-switch in `printFacts()` with polymorphic `toString()` call
- `MatcherAndAgenda.cj`: Added missing `import std.collection.HashSet` for `Agenda` class
- `MatcherAndAgenda.cj`: Fixed `Agenda.fireAll()` to use `if (let l = listener)` idiom for `Option` unwrapping
- `RuleEngine.cj`: Removed incorrect `.toUint64()` conversion on `matches.size` (already `Int64`)
- `PerformanceTest.cj`: Fixed incorrect `.toUint64()` conversions for `Int64` fields (`items`, `salience`)

### Changed
- Updated `.gitignore` to include `cjpm` build artifacts (`build/`, `cjpm.lock`)

## [1.1.0] - 2026-03-08

### Added
- `examples/RiskControlExample.cj` - Real-time risk control system example with 6 test scenarios
- `examples/DynamicPricingExample.cj` - Dynamic pricing engine example with multi-factor pricing rules
- `examples/ApprovalWorkflowExample.cj` - Intelligent approval workflow example with 7 scenarios
- `docs/PERFORMANCE_COMPARISON.md` - Detailed performance comparison analysis vs Java Drools

### Changed
- Updated `README.md` with performance comparison table and new example documentation

## [1.0.0] - 2026-03-01

### Added
- `core/Fact.cj` - Abstract `Fact` base class with `OrderFact`, `ProductFact`, `CustomerFact` implementations
- `core/Rule.cj` - `Rule`, `RuleBuilder`, `Condition`, `PropertyValue`, `RuleListener` classes
- `core/WorkingMemory.cj` - Working memory with HashMap storage and type-based indexing
- `core/MatcherAndAgenda.cj` - `PatternMatcher` and `Agenda` for rule matching and execution
- `core/RuleEngine.cj` - Main rule engine with configuration and statistics
- `examples/DiscountExample.cj` - E-commerce discount rules example
- `tests/unit/FactTest.cj` - Unit tests for Fact classes (10 tests)
- `tests/unit/WorkingMemoryTest.cj` - Unit tests for WorkingMemory (8 tests)
- `tests/unit/RuleEngineTest.cj` - Unit tests for RuleEngine (6 tests)
- `tests/integration/DiscountRulesIntegrationTest.cj` - Integration tests (6 scenarios)
- `tests/performance/PerformanceTest.cj` - Performance benchmarks (4 benchmarks)
- `docs/ARCHITECTURE.md` - Architecture design documentation
- `docs/INSTALL.md` - Installation and usage guide
- `docs/TESTING_REPORT.md` - Testing report
- `README.md` - Project overview and quick start guide
