/*
 * Drools 规则引擎 - 仓颉实现
 * 核心组件: PatternMatcher 和 Agenda
 */

package core

import std.collection.ArrayList
import std.collection.HashSet

// ==================== 模式匹配器 ====================

/**
 * 匹配结果
 */
public class Match {
    public var rule: Rule
    public var facts: ArrayList<Fact>

    public init(rule: Rule, facts: ArrayList<Fact>) {
        this.rule = rule
        this.facts = facts
    }
}

/**
 * 模式匹配器
 * 负责将事实与规则进行匹配
 */
public class PatternMatcher {
    private var workingMemory: WorkingMemory
    private var matchCount: Int64 = 0

    public init(workingMemory: WorkingMemory) {
        this.workingMemory = workingMemory
    }

    /**
     * 匹配所有规则
     */
    public func matchRules(rules: ArrayList<Rule>): ArrayList<Match> {
        var matches = ArrayList<Match>()

        for (rule in rules) {
            if (!rule.enabled) {
                continue
            }

            let ruleMatches = matchRule(rule)
            for (factList in ruleMatches) {
                matches.add(Match(rule, factList))
            }
        }

        return matches
    }

    /**
     * 匹配单个规则
     */
    public func matchRule(rule: Rule): ArrayList<ArrayList<Fact>> {
        var results = ArrayList<ArrayList<Fact>>()

        // 获取所有事实
        let allFacts = workingMemory.getAllFacts()

        // 对每个事实进行规则匹配
        for (fact in allFacts) {
            if (rule.evaluate(fact)) {
                var matched = ArrayList<Fact>()
                matched.add(fact)
                results.add(matched)

                matchCount++
            }
        }

        return results
    }

    /**
     * 增量匹配(新增事实后)
     */
    public func incrementalMatch(rules: ArrayList<Rule>, newFact: Fact): ArrayList<Match> {
        var matches = ArrayList<Match>()

        for (rule in rules) {
            if (!rule.enabled) {
                continue
            }

            if (rule.evaluate(newFact)) {
                var facts = ArrayList<Fact>()
                facts.add(newFact)
                matches.add(Match(rule, facts))
                matchCount++
            }
        }

        return matches
    }

    /**
     * 获取匹配次数
     */
    public func getMatchCount(): Int64 {
        return matchCount
    }

    public func reset() {
        matchCount = 0
    }
}

// ==================== 议程 ====================

/**
 * 激活项
 * 表示一个规则被激活,等待执行
 */
public class Activation {
    public var rule: Rule
    public var facts: ArrayList<Fact>
    public var activated: Bool = false
    public var timestamp: Int64

    public init(rule: Rule, facts: ArrayList<Fact>) {
        this.rule = rule
        this.facts = facts
        let now = DateTime.now()
        this.timestamp = now.toMilliseconds()
    }
}

/**
 * 简单的 DateTime 类(用于时间戳)
 */
class DateTime {
    private var milliseconds: Int64

    private init(milliseconds: Int64) {
        this.milliseconds = milliseconds
    }

    public func toMilliseconds(): Int64 {
        return milliseconds
    }

    public static func now(): DateTime {
        // 简化实现,实际应使用系统时间
        return DateTime(0)
    }
}

/**
 * 议程
 * 管理待执行的规则激活
 */
public class Agenda {
    private var activations: ArrayList<Activation> = ArrayList()
    private var firedRules: HashSet<String> = HashSet()
    private var fireCount: Int64 = 0

    public init() {}

    /**
     * 添加激活
     */
    public func addActivation(rule: Rule, facts: ArrayList<Fact>) {
        // 检查是否已触发(如果是 no-loop 规则)
        if (rule.noLoop && firedRules.contains(rule.name)) {
            return
        }

        let activation = Activation(rule, facts)
        activations.add(activation)
    }

    /**
     * 按优先级排序激活
     */
    public func sortActivations() {
        activations.sort({ a1, a2 =>
            // 先按优先级降序
            let salienceCompare = a2.rule.salience <=> a1.rule.salience
            if (salienceCompare != 0) {
                return salienceCompare
            }
            // 优先级相同则按时间戳升序
            return a1.timestamp <=> a2.timestamp
        })
    }

    /**
     * 触发下一个规则
     */
    public func fireNext(): Int64 {
        // 排序
        sortActivations()

        // 获取下一个未触发的激活
        for (activation in activations) {
            if (!activation.activated) {
                activation.activated = true
                firedRules.add(activation.rule.name)
                fireCount++

                activation.rule.execute()
                return 1
            }
        }

        return 0
    }

    /**
     * 触发所有规则(带监听器)
     */
    public func fireAll(listener: RuleListener?): Int64 {
        var fired = 0

        // 排序
        sortActivations()

        // 触发所有未触发的激活
        for (activation in activations) {
            if (!activation.activated) {
                activation.activated = true
                firedRules.add(activation.rule.name)
                fireCount++

                // 通知监听器
                if (let l = listener) {
                    l.onBeforeExecute(activation.rule, activation.facts[0])
                }

                // 执行规则
                activation.rule.execute()

                // 通知监听器
                if (let l = listener) {
                    l.onAfterExecute(activation.rule, activation.facts[0])
                }

                fired++
            }
        }

        return fired
    }

    /**
     * 清空议程
     */
    public func clear() {
        activations.clear()
        firedRules.clear()
        fireCount = 0
    }

    /**
     * 获取待触发规则数
     */
    public func getPendingCount(): Int64 {
        var count = 0
        for (activation in activations) {
            if (!activation.activated) {
                count++
            }
        }
        return count
    }

    /**
     * 获取已触发规则数
     */
    public func getFiredCount(): Int64 {
        return fireCount
    }

    /**
     * 检查规则是否已触发
     */
    public func isRuleFired(ruleName: String): Bool {
        return firedRules.contains(ruleName)
    }

    /**
     * 打印议程状态
     */
    public func printAgenda() {
        println("\n📋 议程状态:")
        println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        if (activations.isEmpty) {
            println("  (无待触发规则)")
        } else {
            for (activation in activations) {
                let status = if (activation.activated) { "✅" } else { "⏳" }
                println("  ${status} ${activation.rule.name} (优先级: ${activation.rule.salience})")
            }
        }

        println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    }
}
