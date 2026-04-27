/*
 * Drools 规则引擎 - 仓颉实现
 * 文件: RuleEngine.cj
 * 说明: 规则引擎主类,协调所有组件
 */

package core

import std.collection.ArrayList

// ==================== 规则引擎 ====================

/**
 * 规则引擎配置
 */
public class RuleEngineConfig {
    public var enableLog: Bool = true
    public var enableStats: Bool = true
    public var maxFacts: Int64 = 10000

    public init() {}
}

/**
 * 引擎统计信息
 */
public class EngineStats {
    public var totalFactsInserted: Int64 = 0
    public var totalFactsUpdated: Int64 = 0
    public var totalFactsRetracted: Int64 = 0
    public var totalRulesExecuted: Int64 = 0
    public var totalMatches: Int64 = 0

    public init() {}

    public func reset() {
        totalFactsInserted = 0
        totalFactsUpdated = 0
        totalFactsRetracted = 0
        totalRulesExecuted = 0
        totalMatches = 0
    }

    public func toString(): String {
        return """
        📊 引擎统计:
          - 插入事实: ${totalFactsInserted}
          - 更新事实: ${totalFactsUpdated}
          - 撤回事实: ${totalFactsRetracted}
          - 匹配次数: ${totalMatches}
          - 执行规则: ${totalRulesExecuted}
        """
    }
}

/**
 * 规则引擎主类
 */
public class RuleEngine {
    private var workingMemory: WorkingMemory
    private var patternMatcher: PatternMatcher
    private var agenda: Agenda
    private var rules: ArrayList<Rule>
    private var config: RuleEngineConfig
    private var stats: EngineStats
    private var listener: RuleListener?

    public init(config: RuleEngineConfig = RuleEngineConfig()) {
        this.workingMemory = WorkingMemory()
        this.patternMatcher = PatternMatcher(workingMemory)
        this.agenda = Agenda()
        this.rules = ArrayList<Rule>()
        this.config = config
        this.stats = EngineStats()
        this.listener = DefaultRuleListener()
    }

    /**
     * 设置规则监听器
     */
    public func setListener(listener: RuleListener) {
        this.listener = listener
    }

    /**
     * 添加规则
     */
    public func addRule(rule: Rule) {
        rules.add(rule)
        if (config.enableLog) {
            println("[RuleEngine] ✅ 添加规则: ${rule.name} (优先级: ${rule.salience})")
        }
    }

    /**
     * 添加规则(使用构建器)
     */
    public func addRule(builder: RuleBuilder) {
        addRule(builder.build())
    }

    /**
     * 移除规则
     */
    public func removeRule(ruleName: String): Bool {
        for (rule in rules) {
            if (rule.name == ruleName) {
                rules.removeAll({ r => r.name == ruleName })
                if (config.enableLog) {
                    println("[RuleEngine] ➖ 移除规则: ${ruleName}")
                }
                return true
            }
        }
        return false
    }

    /**
     * 插入事实
     */
    public func insert(fact: Fact): Int64 {
        if (workingMemory.getSize() >= config.maxFacts) {
            println("[RuleEngine] ⚠️ 工作内存已满,无法插入事实")
            return -1
        }

        let version = workingMemory.insert(fact)
        stats.totalFactsInserted++

        // 增量匹配
        let matches = patternMatcher.incrementalMatch(rules, fact)
        for (m in matches) {
            stats.totalMatches++
            listener?.onMatch(m.rule, m.facts[0])
            agenda.addActivation(m.rule, m.facts)
        }

        return version
    }

    /**
     * 更新事实
     */
    public func update(fact: Fact): Bool {
        let success = workingMemory.update(fact)
        if (success) {
            stats.totalFactsUpdated++

            // 重新匹配(简化版:触发所有规则的重新评估)
            reevaluateRules()
        }
        return success
    }

    /**
     * 撤回事实
     */
    public func retract(factId: String): Bool {
        let success = workingMemory.retract(factId)
        if (success) {
            stats.totalFactsRetracted++

            // 清理相关的议程项
            agenda.clear()
        }
        return success
    }

    /**
     * 执行所有规则
     */
    public func fireAllRules() {
        if (config.enableLog) {
            println("[RuleEngine] 🚀 开始执行规则...")
            workingMemory.printFacts()
        }

        // 模式匹配
        let matches = patternMatcher.matchRules(rules)
        stats.totalMatches += matches.size

        // 填充议程
        for (m in matches) {
            listener?.onMatch(m.rule, m.facts[0])
            agenda.addActivation(m.rule, m.facts)
        }

        // 触发所有规则
        let firedCount = agenda.fireAll(listener)
        stats.totalRulesExecuted += firedCount

        if (config.enableLog) {
            println("[RuleEngine] ✅ 规则执行完成")
            if (config.enableStats) {
                println(stats.toString())
            }
            println("[RuleEngine] 统计: ${workingMemory.getStats()}")
        }
    }

    /**
     * 重新评估所有规则
     */
    private func reevaluateRules() {
        // 清空议程
        agenda.clear()

        // 重新匹配所有规则
        let matches = patternMatcher.matchRules(rules)
        for (m in matches) {
            agenda.addActivation(m.rule, m.facts)
        }
    }

    /**
     * 获取工作内存
     */
    public func getWorkingMemory(): WorkingMemory {
        return workingMemory
    }

    /**
     * 获取议程
     */
    public func getAgenda(): Agenda {
        return agenda
    }

    /**
     * 获取统计信息
     */
    public func getStats(): EngineStats {
        return stats
    }

    /**
     * 获取所有规则
     */
    public func getRules(): ArrayList<Rule> {
        return rules
    }

    /**
     * 重置引擎
     */
    public func reset() {
        workingMemory.clear()
        agenda.clear()
        stats.reset()

        if (config.enableLog) {
            println("[RuleEngine] 🔄 引擎已重置")
        }
    }

    /**
     * 打印引擎状态
     */
    public func printStatus() {
        println("\n╔══════════════════════════════════════════════════════╗")
        println("║         Drools 规则引擎 - 仓颉实现                    ║")
        println("╚══════════════════════════════════════════════════════╝")
        println("")
        println("📋 规则列表:")
        println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        for (rule in rules) {
            println("  • ${rule.toString()}")
        }

        println("")
        println(stats.toString())
        println(workingMemory.getStats())
        println("待触发规则数: ${agenda.getPendingCount()}")
        println("")
    }
}

// ==================== 引擎构建器 ====================

/**
 * 规则引擎构建器
 */
public class RuleEngineBuilder {
    private var config: RuleEngineConfig

    public init() {
        this.config = RuleEngineConfig()
    }

    public func enableLog(value: Bool): RuleEngineBuilder {
        config.enableLog = value
        return this
    }

    public func enableStats(value: Bool): RuleEngineBuilder {
        config.enableStats = value
        return this
    }

    public func maxFacts(value: Int64): RuleEngineBuilder {
        config.maxFacts = value
        return this
    }

    public func build(): RuleEngine {
        return RuleEngine(config)
    }
}
