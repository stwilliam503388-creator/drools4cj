# Changelog

所有重要的变更都会记录在此文件中。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)，
并遵循 [语义化版本](https://semver.org/lang/zh-CN/)。

## [1.1.0] - 2026-03-12

### 新增
- 新增 `cjpm.toml` 包管理配置文件，符合仓颉三方库标准规范
- 新增 `src/` 标准源码目录，遵循 CangjieSkills 最佳实践
- 新增 `test/LLT/` 低层单元测试目录
- 新增 `test/HLT/` 高层集成测试目录
- 新增 `CHANGELOG.md` 版本变更日志
- 新增 `README.OpenSource` 开源声明文件
- 新增 RiskControlExample.cj 风险控制示例
- 新增 DynamicPricingExample.cj 动态定价示例
- 新增 ApprovalWorkflowExample.cj 审批流程示例
- 新增 `docs/PERFORMANCE_COMPARISON.md` 性能对比报告

### 优化
- 优化 WorkingMemory 中的空值处理逻辑，改进 `getFact()` 和 `getVersion()` 的返回安全性
- 优化 WorkingMemory 类型索引的 retract 方法，修复 `typeIndex` 可能的空引用问题
- 优化 PatternMatcher 的增量匹配逻辑
- 项目目录结构调整为符合仓颉三方库标准（src/, test/LLT/, test/HLT/）

### 文档
- 更新 README.md，新增 cjpm 安装和使用说明
- 更新 docs/INSTALL.md，新增 cjpm 构建方式
- 更新 docs/ARCHITECTURE.md，反映新目录结构

## [1.0.0] - 2026-03-08

### 新增
- 初始版本发布
- 实现核心规则引擎 (RuleEngine)
- 实现工作内存 (WorkingMemory)
- 实现模式匹配器 (PatternMatcher)
- 实现议程 (Agenda)
- 实现事实对象基类和具体实现 (Fact, OrderFact, ProductFact, CustomerFact)
- 实现规则定义和构建器 (Rule, RuleBuilder)
- 添加电商折扣示例 (DiscountExample)
- 添加单元测试套件
- 添加集成测试
- 添加性能基准测试
- 完整文档体系

[1.1.0]: https://github.com/stwilliam503388-creator/drools4cj/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/stwilliam503388-creator/drools4cj/releases/tag/v1.0.0
