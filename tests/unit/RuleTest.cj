/*
 * Drools4Cj - 单元测试
 * 文件: RuleTest.cj
 * 说明: 测试 PropertyValue、Condition、Rule、RuleBuilder 及 DefaultRuleListener
 */

package tests.unit

import core.*
import core.Rule
import core.RuleBuilder
import core.Condition
import core.PropertyValue
import core.DefaultRuleListener
import core.OrderFact
import std.collection.ArrayList

/**
 * Rule 相关类单元测试
 */
class RuleTest {
    private var passed: Int64 = 0
    private var failed: Int64 = 0
    private var tests: ArrayList<String> = ArrayList()

    public init() {}

    private func assert(condition: Bool, message: String) {
        if (condition) {
            passed++
            tests.add("✅ PASS: ${message}")
        } else {
            failed++
            tests.add("❌ FAIL: ${message}")
        }
    }

    private func assertEquals<T>(expected: T, actual: T, message: String) {
        assert(expected == actual, "${message} (expected: ${expected}, actual: ${actual})")
    }

    /**
     * 运行所有测试
     */
    public func runAll(): Bool {
        println("\n╔══════════════════════════════════════════════════════╗")
        println("║      Rule 相关类单元测试                              ║")
        println("╚══════════════════════════════════════════════════════╝\n")

        testPropertyValueInt64()
        testPropertyValueFloat64()
        testPropertyValueString()
        testPropertyValueFallbacks()
        testPropertyValueToString()
        testConditionCreation()
        testConditionToString()
        testRuleCreationDefaults()
        testRuleEvaluateNoConditions()
        testRuleEvaluateWithMatchingCondition()
        testRuleEvaluateWithNonMatchingCondition()
        testRuleEvaluateDisabled()
        testRuleEvaluateMultipleConditions()
        testRuleCompareTo()
        testRuleToString()
        testRuleAddConditionAndAction()
        testRuleBuilderChaining()
        testRuleBuilderNoLoop()
        testRuleBuilderDescription()
        testRuleBuilderGetRule()
        testRuleBuilderIntCondition()
        testRuleBuilderStringCondition()
        testDefaultRuleListener()

        printResults()
        return failed == 0
    }

    // ==================== PropertyValue 测试 ====================

    /**
     * 测试 Int64 PropertyValue
     */
    private func testPropertyValueInt64() {
        println("🧪 测试: PropertyValue Int64 创建与访问")

        let pv = PropertyValue(42)
        assertEquals(42, pv.asInt64(), "Int64 值应为 42")
        assertEquals(0.0, pv.asFloat64(), "Int64 PropertyValue 的 Float64 回退应为 0.0")
        assertEquals("", pv.asString(), "Int64 PropertyValue 的 String 回退应为空字符串")

        println("")
    }

    /**
     * 测试 Float64 PropertyValue
     */
    private func testPropertyValueFloat64() {
        println("🧪 测试: PropertyValue Float64 创建与访问")

        let pv = PropertyValue(3.14)
        assertEquals(3.14, pv.asFloat64(), "Float64 值应为 3.14")
        assertEquals(0, pv.asInt64(), "Float64 PropertyValue 的 Int64 回退应为 0")
        assertEquals("", pv.asString(), "Float64 PropertyValue 的 String 回退应为空字符串")

        println("")
    }

    /**
     * 测试 String PropertyValue
     */
    private func testPropertyValueString() {
        println("🧪 测试: PropertyValue String 创建与访问")

        let pv = PropertyValue("hello")
        assertEquals("hello", pv.asString(), "String 值应为 hello")
        assertEquals(0, pv.asInt64(), "String PropertyValue 的 Int64 回退应为 0")
        assertEquals(0.0, pv.asFloat64(), "String PropertyValue 的 Float64 回退应为 0.0")

        println("")
    }

    /**
     * 测试 PropertyValue 各类型回退默认值
     */
    private func testPropertyValueFallbacks() {
        println("🧪 测试: PropertyValue 回退默认值")

        // Int PropertyValue 的其他类型回退
        let intPv = PropertyValue(100)
        assertEquals(0.0, intPv.asFloat64(), "Int64 PropertyValue Float64 回退应为 0.0")
        assertEquals("", intPv.asString(), "Int64 PropertyValue String 回退应为空")

        // Float PropertyValue 的其他类型回退
        let floatPv = PropertyValue(2.5)
        assertEquals(0, floatPv.asInt64(), "Float64 PropertyValue Int64 回退应为 0")
        assertEquals("", floatPv.asString(), "Float64 PropertyValue String 回退应为空")

        // String PropertyValue 的其他类型回退
        let strPv = PropertyValue("test")
        assertEquals(0, strPv.asInt64(), "String PropertyValue Int64 回退应为 0")
        assertEquals(0.0, strPv.asFloat64(), "String PropertyValue Float64 回退应为 0.0")

        println("")
    }

    /**
     * 测试 PropertyValue toString
     */
    private func testPropertyValueToString() {
        println("🧪 测试: PropertyValue toString")

        let intPv = PropertyValue(99)
        let floatPv = PropertyValue(1.5)
        let strPv = PropertyValue("world")

        assert(intPv.toString().contains("99"), "Int64 toString 应包含值 99")
        assert(floatPv.toString().contains("1.5"), "Float64 toString 应包含值 1.5")
        assertEquals("world", strPv.toString(), "String toString 应直接返回原值")

        println("")
    }

    // ==================== Condition 测试 ====================

    /**
     * 测试 Condition 创建
     */
    private func testConditionCreation() {
        println("🧪 测试: Condition 创建")

        let cond = Condition("amount", ">", PropertyValue(1000.0))
        assertEquals("amount", cond.field, "字段应为 amount")
        assertEquals(">", cond.operator, "操作符应为 >")
        assertEquals(1000.0, cond.value.asFloat64(), "条件值应为 1000.0")

        println("")
    }

    /**
     * 测试 Condition toString
     */
    private func testConditionToString() {
        println("🧪 测试: Condition toString")

        let cond = Condition("items", ">=", PropertyValue(5))
        let str = cond.toString()

        assert(str.contains("items"), "toString 应包含字段名 items")
        assert(str.contains(">="), "toString 应包含操作符 >=")

        let strCond = Condition("customer", "=", PropertyValue("VIP"))
        let strResult = strCond.toString()
        assert(strResult.contains("customer"), "toString 应包含字段名 customer")
        assert(strResult.contains("="), "toString 应包含操作符 =")

        println("")
    }

    // ==================== Rule 测试 ====================

    /**
     * 测试 Rule 创建默认值
     */
    private func testRuleCreationDefaults() {
        println("🧪 测试: Rule 默认值")

        let rule = Rule("默认规则")
        assertEquals("默认规则", rule.name, "规则名称应正确")
        assertEquals(0, rule.salience, "默认优先级应为 0")
        assert(!rule.noLoop, "默认 noLoop 应为 false")
        assert(rule.enabled, "默认规则应为启用状态")
        assertEquals(0, rule.conditions.size, "默认规则不应有条件")
        assertEquals(0, rule.actions.size, "默认规则不应有动作")

        println("")
    }

    /**
     * 测试 无条件规则始终匹配
     */
    private func testRuleEvaluateNoConditions() {
        println("🧪 测试: 无条件规则对任意事实返回 true")

        let rule = Rule("无条件规则")
        let anyFact = OrderFact("O001", "普通", 1.0, 1)

        assert(rule.evaluate(anyFact), "无条件启用规则应对任意事实返回 true")

        println("")
    }

    /**
     * 测试 规则评估 - 条件匹配
     */
    private func testRuleEvaluateWithMatchingCondition() {
        println("🧪 测试: 规则评估 - 条件匹配与不匹配")

        let rule = Rule("金额规则")
        rule.addCondition("amount", ">", PropertyValue(1000.0))

        let matchingFact = OrderFact("O001", "普通", 1500.0, 3)
        let nonMatchingFact = OrderFact("O002", "普通", 500.0, 3)

        assert(rule.evaluate(matchingFact), "金额 1500.0 应匹配 > 1000.0 的规则")
        assert(!rule.evaluate(nonMatchingFact), "金额 500.0 不应匹配 > 1000.0 的规则")

        println("")
    }

    /**
     * 测试 规则评估 - 条件不匹配
     */
    private func testRuleEvaluateWithNonMatchingCondition() {
        println("🧪 测试: 规则评估 - VIP 条件不匹配普通客户")

        let rule = Rule("VIP规则")
        rule.addCondition("customer", "=", PropertyValue("VIP"))

        let normalFact = OrderFact("O001", "普通", 1000.0, 5)
        assert(!rule.evaluate(normalFact), "普通客户不应匹配 VIP 规则")

        println("")
    }

    /**
     * 测试 禁用规则始终不匹配
     */
    private func testRuleEvaluateDisabled() {
        println("🧪 测试: 禁用规则对任意事实返回 false")

        let rule = Rule("禁用规则")
        rule.addCondition("amount", ">", PropertyValue(100.0))
        rule.setEnabled(false)

        // 无论事实满不满足条件,禁用规则应返回 false
        let matchingFact = OrderFact("O001", "普通", 5000.0, 3)
        assert(!rule.evaluate(matchingFact), "禁用规则应始终返回 false")

        let nonMatchingFact = OrderFact("O002", "普通", 50.0, 1)
        assert(!rule.evaluate(nonMatchingFact), "禁用规则对不匹配事实也应返回 false")

        println("")
    }

    /**
     * 测试 多条件规则的 AND 逻辑
     */
    private func testRuleEvaluateMultipleConditions() {
        println("🧪 测试: 多条件规则 AND 逻辑")

        let rule = Rule("多条件规则")
        rule.addCondition("amount", ">", PropertyValue(1000.0))
        rule.addCondition("customer", "=", PropertyValue("VIP"))

        // 两个条件都满足
        let bothMatch = OrderFact("O001", "VIP", 1500.0, 5)
        assert(rule.evaluate(bothMatch), "同时满足两个条件时规则应匹配")

        // 只满足金额条件,不满足客户条件
        let onlyAmount = OrderFact("O002", "普通", 1500.0, 5)
        assert(!rule.evaluate(onlyAmount), "只满足金额条件时规则不应匹配")

        // 只满足客户条件,不满足金额条件
        let onlyCustomer = OrderFact("O003", "VIP", 500.0, 5)
        assert(!rule.evaluate(onlyCustomer), "只满足客户条件时规则不应匹配")

        // 两个条件都不满足
        let noneMatch = OrderFact("O004", "普通", 500.0, 5)
        assert(!rule.evaluate(noneMatch), "两个条件都不满足时规则不应匹配")

        println("")
    }

    /**
     * 测试 规则优先级比较
     */
    private func testRuleCompareTo() {
        println("🧪 测试: Rule compareTo 优先级比较")

        let highRule = Rule("高优先级规则", 100)
        let lowRule = Rule("低优先级规则", 50)
        let sameRule = Rule("同优先级规则", 100)

        assert(highRule.compareTo(lowRule) > 0, "高优先级与低优先级比较应为正数")
        assert(lowRule.compareTo(highRule) < 0, "低优先级与高优先级比较应为负数")
        assertEquals(0, highRule.compareTo(sameRule), "相同优先级比较应为 0")

        println("")
    }

    /**
     * 测试 Rule toString
     */
    private func testRuleToString() {
        println("🧪 测试: Rule toString")

        let rule = Rule("字符串规则", 75)
        rule.addCondition("amount", ">", PropertyValue(500.0))
        let str = rule.toString()

        assert(str.contains("字符串规则"), "toString 应包含规则名称")
        assert(str.contains("75"), "toString 应包含优先级")

        println("")
    }

    /**
     * 测试 Rule addCondition 和 addAction
     */
    private func testRuleAddConditionAndAction() {
        println("🧪 测试: Rule addCondition 和 addAction")

        let rule = Rule("动作测试规则")
        rule.addCondition("amount", ">", PropertyValue(100.0))
        rule.addCondition("items", ">=", PropertyValue(2))

        assertEquals(2, rule.conditions.size, "应有 2 个条件")

        var actionCount = 0
        rule.addAction({ actionCount++ })
        rule.addAction({ actionCount++ })

        assertEquals(2, rule.actions.size, "应有 2 个动作")

        // 执行规则动作
        rule.execute()
        assertEquals(2, actionCount, "应执行所有动作")

        println("")
    }

    // ==================== RuleBuilder 测试 ====================

    /**
     * 测试 RuleBuilder 链式调用
     */
    private func testRuleBuilderChaining() {
        println("🧪 测试: RuleBuilder 链式调用")

        var actionExecuted = false

        let rule = RuleBuilder("链式构建规则")
            .salience(75)
            .when("amount", ">", PropertyValue(500.0))
            .when("items", ">=", PropertyValue(3))
            .then({ actionExecuted = true })
            .build()

        assertEquals("链式构建规则", rule.name, "规则名称应正确")
        assertEquals(75, rule.salience, "优先级应为 75")
        assertEquals(2, rule.conditions.size, "应有 2 个条件")
        assertEquals(1, rule.actions.size, "应有 1 个动作")

        // 执行动作验证
        rule.execute()
        assert(actionExecuted, "规则动作应被执行")

        println("")
    }

    /**
     * 测试 RuleBuilder noLoop 设置
     */
    private func testRuleBuilderNoLoop() {
        println("🧪 测试: RuleBuilder noLoop 设置")

        let noLoopRule = RuleBuilder("NoLoop规则")
            .noLoop(true)
            .when("amount", ">", PropertyValue(100.0))
            .then({ })
            .build()

        assert(noLoopRule.noLoop, "noLoop 应为 true")

        let normalRule = RuleBuilder("普通规则")
            .noLoop(false)
            .build()

        assert(!normalRule.noLoop, "noLoop 应为 false")

        println("")
    }

    /**
     * 测试 RuleBuilder description 设置
     */
    private func testRuleBuilderDescription() {
        println("🧪 测试: RuleBuilder description 设置")

        let rule = RuleBuilder("描述规则")
            .description("这是规则描述信息")
            .salience(10)
            .build()

        assertEquals("描述规则", rule.name, "带描述的规则名称应正确")
        assertEquals(10, rule.salience, "带描述的规则优先级应正确")

        println("")
    }

    /**
     * 测试 RuleBuilder getRule 获取中间状态规则
     */
    private func testRuleBuilderGetRule() {
        println("🧪 测试: RuleBuilder getRule 获取中间状态")

        let builder = RuleBuilder("中间规则")
        builder.salience(60)
        builder.when("amount", ">", PropertyValue(200.0))

        let intermediateRule = builder.getRule()

        assertEquals("中间规则", intermediateRule.name, "中间状态规则名称应正确")
        assertEquals(60, intermediateRule.salience, "中间状态优先级应正确")
        assertEquals(1, intermediateRule.conditions.size, "中间状态应有 1 个条件")

        // getRule 和 build 应返回同一规则对象
        let builtRule = builder.build()
        assertEquals("中间规则", builtRule.name, "build 后规则名称应相同")

        println("")
    }

    /**
     * 测试 RuleBuilder Int64 条件
     */
    private func testRuleBuilderIntCondition() {
        println("🧪 测试: RuleBuilder Int64 条件")

        let rule = RuleBuilder("整数条件规则")
            .when("items", ">", PropertyValue(5))
            .build()

        assertEquals(1, rule.conditions.size, "应有 1 个整数条件")

        let matchFact = OrderFact("O001", "普通", 100.0, 10)
        let noMatchFact = OrderFact("O002", "普通", 100.0, 3)

        assert(rule.evaluate(matchFact), "商品数 10 应匹配 > 5 的规则")
        assert(!rule.evaluate(noMatchFact), "商品数 3 不应匹配 > 5 的规则")

        println("")
    }

    /**
     * 测试 RuleBuilder String 条件
     */
    private func testRuleBuilderStringCondition() {
        println("🧪 测试: RuleBuilder String 条件")

        let rule = RuleBuilder("字符串条件规则")
            .when("customer", "=", PropertyValue("VIP"))
            .build()

        assertEquals(1, rule.conditions.size, "应有 1 个字符串条件")

        let vipFact = OrderFact("O001", "VIP", 100.0, 3)
        let normalFact = OrderFact("O002", "普通", 100.0, 3)

        assert(rule.evaluate(vipFact), "VIP 客户应匹配字符串条件")
        assert(!rule.evaluate(normalFact), "普通客户不应匹配 VIP 字符串条件")

        println("")
    }

    // ==================== DefaultRuleListener 测试 ====================

    /**
     * 测试 DefaultRuleListener 方法正常调用
     */
    private func testDefaultRuleListener() {
        println("🧪 测试: DefaultRuleListener 方法调用")

        let listener = DefaultRuleListener()
        let rule = Rule("监听规则", 10)
        rule.addCondition("amount", ">", PropertyValue(100.0))
        let fact = OrderFact("O001", "普通", 200.0, 2)

        // 验证所有监听器方法可调用而不抛出异常
        listener.onMatch(rule, fact)
        listener.onBeforeExecute(rule, fact)
        listener.onAfterExecute(rule, fact)

        assert(true, "DefaultRuleListener 所有方法应正常调用")

        println("")
    }

    /**
     * 打印测试结果
     */
    private func printResults() {
        println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        println("📊 测试结果统计:")
        println("  总计: ${passed + failed}")
        println("  ✅ 通过: ${passed}")
        println("  ❌ 失败: ${failed}")
        println("  通过率: ${((passed * 100) / (passed + failed))}%")
        println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        if (failed > 0) {
            println("\n❌ 失败的测试:")
            for (test in tests) {
                if (test.contains("FAIL")) {
                    println("  ${test}")
                }
            }
        }

        println("\n" + "=".repeat(50))
    }
}

/**
 * 主函数 - 运行 Rule 测试
 */
main() {
    let test = RuleTest()
    let success = test.runAll()

    if (success) {
        println("\n🎉 所有测试通过!")
        System.exit(0)
    } else {
        println("\n⚠️ 存在失败的测试!")
        System.exit(1)
    }
}
