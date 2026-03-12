# Changelog

所有重要变更都会记录在此文件中。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)，
版本号遵循 [语义化版本](https://semver.org/lang/zh-CN/)。

---

## [1.2.0] - 2026-03-12

### 新增
- 添加 `cjpm.toml` 包描述文件，支持标准仓颉包管理工具 (`cjpm`)
- 在 `Fact` 抽象基类中新增 `toString()` 抽象方法，实现多态打印
- 在 `Rule` 类中新增 `getDescription()` 方法，完善 API
- 更新 `.gitignore`，添加 cjpm 构建产物规则

### 修复
- 修复 `MatcherAndAgenda.cj` 中缺少 `import std.collection.HashSet` 导致的编译错误
- 修复 `WorkingMemory.getFact()` 方法：对不存在的 ID 现在正确返回 `None`
- 修复 `WorkingMemory.getVersion()` 方法：对不存在的 ID 现在正确返回 `None`
- 修复 `RuleEngine.fireAllRules()` 中不必要的 `toUint64()` 类型转换

### 优化
- 重构 `WorkingMemory.printFacts()` 方法，使用多态 `toString()` 替代类型分支，
  使代码更简洁并支持自定义 `Fact` 子类
- 将 `OrderFact`、`ProductFact`、`CustomerFact` 的 `toString()` 方法改为 `override`，
  符合仓颉语言规范

---

## [1.1.0] - 2026-03-08

### 新增
- 新增风控系统示例 (`examples/RiskControlExample.cj`)
- 新增动态定价引擎示例 (`examples/DynamicPricingExample.cj`)
- 新增智能审批流程示例 (`examples/ApprovalWorkflowExample.cj`)
- 新增性能对比报告 (`docs/PERFORMANCE_COMPARISON.md`)

### 优化
- 更新 `README.md`，添加详细性能数据和示例说明
- 完善架构文档

---

## [1.0.0] - 2026-03-01

### 新增
- 初始版本发布
- 实现 `WorkingMemory`（工作内存）：支持 O(1) 事实插入/查找，类型索引，版本控制
- 实现 `PatternMatcher`（模式匹配器）：全量匹配与增量匹配
- 实现 `Agenda`（议程）：激活管理、优先级排序、no-loop 支持
- 实现 `RuleEngine`（规则引擎）：完整生命周期管理、统计信息、事件监听
- 实现 `Rule` 与 `RuleBuilder`：流式 API 构建规则
- 实现基础事实类型：`OrderFact`、`ProductFact`、`CustomerFact`
- 提供 `DefaultRuleListener` 默认监听器实现
- 示例：电商折扣规则 (`examples/DiscountExample.cj`)
- 单元测试：`FactTest`、`WorkingMemoryTest`、`RuleEngineTest`
- 集成测试：`DiscountRulesIntegrationTest`
- 性能测试：`PerformanceTest`
- 文档：架构设计、安装指南、贡献指南、测试报告
