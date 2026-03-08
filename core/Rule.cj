/*
 * Drools 规则引擎 - 仓颉实现
 * 文件: Rule.cj
 * 说明: 规则定义、条件、动作及相关类
 */

package core

import std.collection.ArrayList

// ==================== 条件类 ====================

/**
 * 条件值支持多种类型
 */
public class PropertyValue {
    private var intValue: Int64? = None
    private var floatValue: Float64? = None
    private var stringValue: String? = None

    public init(value: Int64) {
        this.intValue = value
    }

    public init(value: Float64) {
        this.floatValue = value
    }

    public init(value: String) {
        this.stringValue = value
    }

    public func asInt64(): Int64 {
        match (intValue) {
            case Some(v) => return v
            case None => return 0
        }
    }

    public func asFloat64(): Float64 {
        match (floatValue) {
            case Some(v) => return v
            case None => return 0.0
        }
    }

    public func asString(): String {
        match (stringValue) {
            case Some(v) => return v
            case None => return ""
        }
    }

    public func toString(): String {
        if (let v = intValue) {
            return "${v}"
        } else if (let v = floatValue) {
            return "${v}"
        } else if (let v = stringValue) {
            return v
        }
        return ""
    }
}

/**
 * 规则条件
 */
public class Condition {
    public var field: String
    public var operator: String
    public var value: PropertyValue

    public init(field: String, operator: String, value: PropertyValue) {
        this.field = field
        this.operator = operator
        this.value = value
    }

    public func toString(): String {
        return "${field} ${operator} ${value.toString()}"
    }
}

// ==================== 规则类 ====================

/**
 * 动作类型: 无参数函数
 */
public type Action = () -> Unit

/**
 * 规则类
 */
public class Rule {
    public var name: String
    public var salience: Int64        // 优先级(越大越优先)
    public var noLoop: Bool            // 是否禁止循环触发
    public var enabled: Bool           // 是否启用
    public var conditions: ArrayList<Condition>
    public var actions: ArrayList<Action>
    private var description: String

    public init(name: String, salience: Int64 = 0) {
        this.name = name
        this.salience = salience
        this.noLoop = false
        this.enabled = true
        this.conditions = ArrayList<Condition>()
        this.actions = ArrayList<Action>()
        this.description = ""
    }

    /**
     * 添加条件
     */
    public func addCondition(field: String, operator: String, value: PropertyValue) {
        conditions.add(Condition(field, operator, value))
    }

    /**
     * 添加动作
     */
    public func addAction(action: Action) {
        actions.add(action)
    }

    /**
     * 设置描述
     */
    public func setDescription(desc: String) {
        this.description = desc
    }

    /**
     * 设置禁止循环
     */
    public func setNoLoop(value: Bool) {
        this.noLoop = value
    }

    /**
     * 启用/禁用规则
     */
    public func setEnabled(value: Bool) {
        this.enabled = value
    }

    /**
     * 评估事实是否匹配所有条件
     */
    public func evaluate(fact: Fact): Bool {
        if (!enabled) {
            return false
        }

        for (condition in conditions) {
            if (!fact.matches(condition)) {
                return false
            }
        }
        return true
    }

    /**
     * 执行规则所有动作
     */
    public func execute() {
        println("    → 执行规则: ${name}")
        for (action in actions) {
            action()
        }
    }

    /**
     * 比较规则优先级(用于排序)
     */
    public func compareTo(other: Rule): Int64 {
        return this.salience - other.salience
    }

    public func toString(): String {
        var sb = "Rule[name=${name}, salience=${salience}"
        if (!conditions.isEmpty) {
            sb += ", conditions=["
            var first = true
            for (cond in conditions) {
                if (!first) sb += ", "
                sb += cond.toString()
                first = false
            }
            sb += "]"
        }
        sb += ", actions=${actions.size}]"
        return sb
    }
}

// ==================== 规则构建器 ====================

/**
 * 规则构建器
 * 提供流式 API 便于构建规则
 */
public class RuleBuilder {
    private var rule: Rule

    public init(name: String) {
        this.rule = Rule(name)
    }

    /**
     * 设置优先级
     */
    public func salience(value: Int64): RuleBuilder {
        rule.salience = value
        return this
    }

    /**
     * 设置描述
     */
    public func description(desc: String): RuleBuilder {
        rule.setDescription(desc)
        return this
    }

    /**
     * 设置禁止循环
     */
    public func noLoop(value: Bool): RuleBuilder {
        rule.setNoLoop(value)
        return this
    }

    /**
     * 添加条件(整数)
     */
    public func when(field: String, operator: String, value: Int64): RuleBuilder {
        rule.addCondition(field, operator, PropertyValue(value))
        return this
    }

    /**
     * 添加条件(浮点数)
     */
    public func when(field: String, operator: String, value: Float64): RuleBuilder {
        rule.addCondition(field, operator, PropertyValue(value))
        return this
    }

    /**
     * 添加条件(字符串)
     */
    public func when(field: String, operator: String, value: String): RuleBuilder {
        rule.addCondition(field, operator, PropertyValue(value))
        return this
    }

    /**
     * 添加动作
     */
    public func then(action: Action): RuleBuilder {
        rule.addAction(action)
        return this
    }

    /**
     * 构建规则
     */
    public func build(): Rule {
        return rule
    }

    /**
     * 获取当前规则(用于连续添加多个条件)
     */
    public func getRule(): Rule {
        return rule
    }
}

// ==================== 规则监听器 ====================

/**
 * 规则执行监听器
 */
public interface RuleListener {
    func onBeforeExecute(rule: Rule, fact: Fact)
    func onAfterExecute(rule: Rule, fact: Fact)
    func onMatch(rule: Rule, fact: Fact)
}

/**
 * 默认监听器实现
 */
public class DefaultRuleListener : RuleListener {
    public init() {}

    public func onBeforeExecute(rule: Rule, fact: Fact) {
        println("  🔔 准备执行规则: ${rule.name} on ${fact.type}:${fact.id}")
    }

    public func onAfterExecute(rule: Rule, fact: Fact) {
        println("  ✅ 规则执行完成: ${rule.name}")
    }

    public func onMatch(rule: Rule, fact: Fact) {
        println("  🎯 规则匹配: ${rule.name} ← ${fact.type}:${fact.id}")
    }
}
