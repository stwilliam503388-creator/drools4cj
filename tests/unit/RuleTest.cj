/*
 * Drools4Cj - 单元测试
 * 文件: RuleTest.cj
 * 说明: 测试 Rule, RuleBuilder, PropertyValue, Condition 和 DefaultRuleListener 类
 */

package tests.unit

import core.*
import core.Rule
import core.RuleBuilder
import core.PropertyValue
import core.Condition
import core.OrderFact
import core.DefaultRuleListener

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
        println("║         Rule 类单元测试                              ║")
        println("╚══════════════════════════════════════════════════════╝\n")

        testPropertyValueInt()
        testPropertyValueFloat()
        testPropertyValueString()
        testPropertyValueToString()
        testPropertyValueCrossTypeAccess()
        testConditionCreation()
        testConditionToString()
        testRuleCreation()
        testRuleSetEnabled()
        testRuleSetNoLoop()
        testRuleEvaluateWithNoConditions()
        testRuleEvaluateWhenDisabled()
        testRuleEvaluateWithSingleCondition()
        testRuleEvaluateWithMultipleConditions()
        testRuleAddAction()
        testRuleCompareTo()
        testRuleToString()
        testRuleBuilderFluent()
        testRuleBuilderMultipleConditions()
        testRuleBuilderIntAndStringConditions()
        testRuleBuilderGetRule()
        testDefaultRuleListener()

        printResults()
        return failed == 0
    }

    // ==================== PropertyValue 测试 ====================

    /**
     * 测试 PropertyValue 整数类型
     */
    private func testPropertyValueInt() {
        println("🧪 测试: PropertyValue 整数类型")

        let pv = PropertyValue(42)

        assertEquals(42, pv.asInt64(), "asInt64 应返回 42")
        assertEquals(0.0, pv.asFloat64(), "asFloat64 应返回默认值 0.0")
        assertEquals("", pv.asString(), "asString 应返回默认值 ''")

        println("")
    }

    /**
     * 测试 PropertyValue 浮点类型
     */
    private func testPropertyValueFloat() {
        println("🧪 测试: PropertyValue 浮点类型")

        let pv = PropertyValue(3.14)

        assertEquals(3.14, pv.asFloat64(), "asFloat64 应返回 3.14")
        assertEquals(0, pv.asInt64(), "asInt64 应返回默认值 0")
        assertEquals("", pv.asString(), "asString 应返回默认值 ''")

        println("")
    }

    /**
     * 测试 PropertyValue 字符串类型
     */
    private func testPropertyValueString() {
        println("🧪 测试: PropertyValue 字符串类型")

        let pv = PropertyValue("hello")

        assertEquals("hello", pv.asString(), "asString 应返回 'hello'")
        assertEquals(0, pv.asInt64(), "asInt64 应返回默认值 0")
        assertEquals(0.0, pv.asFloat64(), "asFloat64 应返回默认值 0.0")

        println("")
    }

    /**
     * 测试 PropertyValue toString()
     */
    private func testPropertyValueToString() {
        println("🧪 测试: PropertyValue toString()")

        let intPv = PropertyValue(100)
        let strPv = PropertyValue("test")

        assert(intPv.toString() == "100", "整数 PropertyValue.toString() 应返回 '100'")
        assert(strPv.toString() == "test", "字符串 PropertyValue.toString() 应返回 'test'")

        println("")
    }

    /**
     * 测试 PropertyValue 跨类型访问返回默认值
     */
    private func testPropertyValueCrossTypeAccess() {
        println("🧪 测试: PropertyValue 跨类型访问返回默认值")

        let intPv = PropertyValue(10)
        assertEquals(0.0, intPv.asFloat64(), "整数 PropertyValue.asFloat64() 应返回 0.0")
        assertEquals("", intPv.asString(), "整数 PropertyValue.asString() 应返回 ''")

        let floatPv = PropertyValue(1.0)
        assertEquals(0, floatPv.asInt64(), "浮点 PropertyValue.asInt64() 应返回 0")
        assertEquals("", floatPv.asString(), "浮点 PropertyValue.asString() 应返回 ''")

        let strPv = PropertyValue("abc")
        assertEquals(0, strPv.asInt64(), "字符串 PropertyValue.asInt64() 应返回 0")
        assertEquals(0.0, strPv.asFloat64(), "字符串 PropertyValue.asFloat64() 应返回 0.0")

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
        assertEquals(">", cond.operator, "运算符应为 >")
        assertEquals(1000.0, cond.value.asFloat64(), "值应为 1000.0")

        let condInt = Condition("items", "<=", PropertyValue(5))
        assertEquals("items", condInt.field, "字段应为 items")
        assertEquals("<=", condInt.operator, "运算符应为 <=")
        assertEquals(5, condInt.value.asInt64(), "值应为 5")

        println("")
    }

    /**
     * 测试 Condition toString()
     */
    private func testConditionToString() {
        println("🧪 测试: Condition toString()")

        let cond = Condition("amount", ">", PropertyValue(1000.0))
        let str = cond.toString()

        assert(str.contains("amount"), "toString 应包含字段名 amount")
        assert(str.contains(">"), "toString 应包含运算符 >")

        println("")
    }

    // ==================== Rule 测试 ====================

    /**
     * 测试 Rule 创建
     */
    private func testRuleCreation() {
        println("🧪 测试: Rule 创建")

        let rule = Rule("测试规则", 50)

        assertEquals("测试规则", rule.name, "规则名应正确")
        assertEquals(50, rule.salience, "优先级应为 50")
        assert(!rule.noLoop, "默认 noLoop 应为 false")
        assert(rule.enabled, "默认 enabled 应为 true")
        assertEquals(0, rule.conditions.size, "初始条件数应为 0")
        assertEquals(0, rule.actions.size, "初始动作数应为 0")

        // 测试默认优先级为 0
        let defaultRule = Rule("默认规则")
        assertEquals(0, defaultRule.salience, "默认优先级应为 0")

        println("")
    }

    /**
     * 测试 Rule setEnabled()
     */
    private func testRuleSetEnabled() {
        println("🧪 测试: Rule setEnabled()")

        let rule = Rule("测试规则")

        assert(rule.enabled, "初始应为启用")

        rule.setEnabled(false)
        assert(!rule.enabled, "禁用后应为 false")

        rule.setEnabled(true)
        assert(rule.enabled, "重新启用后应为 true")

        println("")
    }

    /**
     * 测试 Rule setNoLoop()
     */
    private func testRuleSetNoLoop() {
        println("🧪 测试: Rule setNoLoop()")

        let rule = Rule("测试规则")

        assert(!rule.noLoop, "初始 noLoop 应为 false")

        rule.setNoLoop(true)
        assert(rule.noLoop, "设置后 noLoop 应为 true")

        rule.setNoLoop(false)
        assert(!rule.noLoop, "重置后 noLoop 应为 false")

        println("")
    }

    /**
     * 测试 Rule evaluate() - 无条件时应返回 true
     */
    private func testRuleEvaluateWithNoConditions() {
        println("🧪 测试: Rule evaluate() - 无条件时应返回 true")

        let rule = Rule("无条件规则")
        let fact = OrderFact("ORDER-001", "普通", 100.0, 1)

        assert(rule.evaluate(fact), "无条件规则应匹配所有事实")

        println("")
    }

    /**
     * 测试 Rule evaluate() - 禁用规则应返回 false
     */
    private func testRuleEvaluateWhenDisabled() {
        println("🧪 测试: Rule evaluate() - 禁用规则应返回 false")

        let rule = Rule("禁用规则")
        rule.addCondition("amount", ">", PropertyValue(100.0))
        rule.setEnabled(false)

        let fact = OrderFact("ORDER-001", "普通", 500.0, 3)
        assert(!rule.evaluate(fact), "禁用规则不应匹配任何事实")

        println("")
    }

    /**
     * 测试 Rule evaluate() - 单条件评估
     */
    private func testRuleEvaluateWithSingleCondition() {
        println("🧪 测试: Rule evaluate() - 单条件评估")

        let rule = Rule("金额规则")
        rule.addCondition("amount", ">", PropertyValue(1000.0))

        let matchingFact = OrderFact("ORDER-001", "普通", 1500.0, 3)
        let nonMatchingFact = OrderFact("ORDER-002", "普通", 500.0, 3)

        assert(rule.evaluate(matchingFact), "金额 1500 > 1000 的订单应匹配")
        assert(!rule.evaluate(nonMatchingFact), "金额 500 > 1000 的订单不应匹配")

        println("")
    }

    /**
     * 测试 Rule evaluate() - 多条件必须全部满足
     */
    private func testRuleEvaluateWithMultipleConditions() {
        println("🧪 测试: Rule evaluate() - 多条件必须全部满足")

        let rule = Rule("复合规则")
        rule.addCondition("amount", ">", PropertyValue(1000.0))
        rule.addCondition("items", ">", PropertyValue(5))

        assertEquals(2, rule.conditions.size, "规则应有 2 个条件")

        // 满足所有条件
        let fullMatch = OrderFact("ORDER-001", "普通", 1500.0, 10)
        assert(rule.evaluate(fullMatch), "满足所有条件的事实应匹配")

        // 只满足金额条件,不满足商品数条件
        let partialMatch1 = OrderFact("ORDER-002", "普通", 1500.0, 3)
        assert(!rule.evaluate(partialMatch1), "只满足金额条件不应匹配")

        // 只满足商品数条件,不满足金额条件
        let partialMatch2 = OrderFact("ORDER-003", "普通", 500.0, 10)
        assert(!rule.evaluate(partialMatch2), "只满足商品数条件不应匹配")

        // 都不满足
        let noMatch = OrderFact("ORDER-004", "普通", 500.0, 3)
        assert(!rule.evaluate(noMatch), "不满足任何条件的事实不应匹配")

        println("")
    }

    /**
     * 测试 Rule addAction() 和 execute()
     */
    private func testRuleAddAction() {
        println("🧪 测试: Rule addAction() 和 execute()")

        let rule = Rule("执行规则")
        var count = 0

        rule.addAction({ count++ })
        rule.addAction({ count++ })

        assertEquals(2, rule.actions.size, "应有 2 个动作")

        rule.execute()

        assertEquals(2, count, "执行后计数器应为 2")

        println("")
    }

    /**
     * 测试 Rule compareTo()
     */
    private func testRuleCompareTo() {
        println("🧪 测试: Rule compareTo()")

        let highRule = Rule("高优先级", 100)
        let lowRule = Rule("低优先级", 50)
        let sameRule = Rule("相同优先级", 100)

        assert(highRule.compareTo(lowRule) > 0, "高优先级规则应大于低优先级规则")
        assert(lowRule.compareTo(highRule) < 0, "低优先级规则应小于高优先级规则")
        assertEquals(0, highRule.compareTo(sameRule), "相同优先级规则比较应为 0")

        println("")
    }

    /**
     * 测试 Rule toString()
     */
    private func testRuleToString() {
        println("🧪 测试: Rule toString()")

        let rule = Rule("测试规则", 100)
        rule.addCondition("amount", ">", PropertyValue(1000.0))
        rule.addAction({ })

        let str = rule.toString()
        assert(str.contains("测试规则"), "toString 应包含规则名")
        assert(str.contains("100"), "toString 应包含优先级")

        // 无条件规则的 toString
        let simpleRule = Rule("简单规则", 0)
        let simpleStr = simpleRule.toString()
        assert(simpleStr.contains("简单规则"), "简单规则 toString 应包含规则名")

        println("")
    }

    // ==================== RuleBuilder 测试 ====================

    /**
     * 测试 RuleBuilder 流式 API
     */
    private func testRuleBuilderFluent() {
        println("🧪 测试: RuleBuilder 流式 API")

        let rule = RuleBuilder("流式规则")
            .salience(200)
            .description("测试描述")
            .noLoop(true)
            .when("amount", ">", PropertyValue(500.0))
            .then({ })
            .build()

        assertEquals("流式规则", rule.name, "规则名应正确")
        assertEquals(200, rule.salience, "优先级应为 200")
        assert(rule.noLoop, "noLoop 应为 true")
        assertEquals(1, rule.conditions.size, "应有 1 个条件")
        assertEquals(1, rule.actions.size, "应有 1 个动作")

        println("")
    }

    /**
     * 测试 RuleBuilder 多条件
     */
    private func testRuleBuilderMultipleConditions() {
        println("🧪 测试: RuleBuilder 多条件")

        let rule = RuleBuilder("多条件规则")
            .when("amount", ">", PropertyValue(1000.0))
            .when("items", ">", PropertyValue(5))
            .when("customer", "=", PropertyValue("VIP"))
            .build()

        assertEquals(3, rule.conditions.size, "应有 3 个条件")

        // 验证每个条件字段正确
        assertEquals("amount", rule.conditions[0].field, "第一个条件字段应为 amount")
        assertEquals("items", rule.conditions[1].field, "第二个条件字段应为 items")
        assertEquals("customer", rule.conditions[2].field, "第三个条件字段应为 customer")

        println("")
    }

    /**
     * 测试 RuleBuilder 整数和字符串条件重载
     */
    private func testRuleBuilderIntAndStringConditions() {
        println("🧪 测试: RuleBuilder 整数和字符串条件重载")

        // 测试整数条件
        let intRule = RuleBuilder("整数条件规则")
            .when("items", ">=", PropertyValue(10))
            .build()

        assertEquals(1, intRule.conditions.size, "应有 1 个整数条件")
        assertEquals(10, intRule.conditions[0].value.asInt64(), "整数条件值应为 10")

        // 测试字符串条件
        let strRule = RuleBuilder("字符串条件规则")
            .when("customer", "=", PropertyValue("VIP"))
            .build()

        assertEquals(1, strRule.conditions.size, "应有 1 个字符串条件")
        assertEquals("VIP", strRule.conditions[0].value.asString(), "字符串条件值应为 VIP")

        println("")
    }

    /**
     * 测试 RuleBuilder getRule()
     */
    private func testRuleBuilderGetRule() {
        println("🧪 测试: RuleBuilder getRule()")

        let builder = RuleBuilder("测试规则")
        builder.salience(100)

        let rule1 = builder.getRule()
        let rule2 = builder.build()

        assertEquals("测试规则", rule1.name, "getRule 应返回规则名")
        assertEquals("测试规则", rule2.name, "build 应返回规则名")
        assertEquals(100, rule1.salience, "getRule 返回的规则优先级应正确")

        println("")
    }

    // ==================== DefaultRuleListener 测试 ====================

    /**
     * 测试 DefaultRuleListener
     */
    private func testDefaultRuleListener() {
        println("🧪 测试: DefaultRuleListener")

        let listener = DefaultRuleListener()
        let rule = Rule("测试规则", 100)
        let fact = OrderFact("ORDER-001", "普通", 1000.0, 5)

        // 这些方法只输出日志,不应抛出异常
        listener.onBeforeExecute(rule, fact)
        listener.onAfterExecute(rule, fact)
        listener.onMatch(rule, fact)

        assert(true, "DefaultRuleListener 方法应正常执行")

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
