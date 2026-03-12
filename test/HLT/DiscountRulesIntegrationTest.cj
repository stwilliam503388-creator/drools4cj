/*
 * Drools4Cj - 集成测试
 * 文件: DiscountRulesIntegrationTest.cj
 * 说明: 测试完整的折扣规则场景
 */

package tests.integration

import core.*
import core.RuleEngine
import core.RuleBuilder
import core.OrderFact
import core.PropertyValue

/**
 * 折扣规则集成测试
 * 测试真实的业务场景
 */
class DiscountRulesIntegrationTest {
    private var passed: Int64 = 0
    private var failed: Int64 = 0
    private var tests: ArrayList<String> = ArrayList()

    // 测试结果收集
    private var triggeredRules: ArrayList<String> = ArrayList()

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

    /**
     * 运行所有测试
     */
    public func runAll(): Bool {
        println("\n╔══════════════════════════════════════════════════════╗")
        println("║      折扣规则集成测试                                ║")
        println("╚══════════════════════════════════════════════════════╝\n")

        testSingleRuleMatching()
        testMultipleRulesMatching()
        testRulePriority()
        testVIPCustomerDiscount()
        testComplexScenario()
        testNoMatchScenario()

        printResults()
        return failed == 0
    }

    /**
     * 场景 1: 单规则匹配
     */
    private func testSingleRuleMatching() {
        println("🧪 场景 1: 单规则匹配")

        triggeredRules.clear()

        let engine = RuleEngine()

        engine.addRule(
            RuleBuilder("订单金额折扣")
                .salience(100)
                .when("amount", ">", PropertyValue(1000.0))
                .then({
                    triggeredRules.add("订单金额折扣")
                })
                .build()
        )

        // 插入匹配的订单
        engine.insert(OrderFact("ORDER-001", "普通", 1200.0, 5))
        engine.fireAllRules()

        assert(triggeredRules.contains("订单金额折扣"), "应触发订单金额折扣规则")

        println("")
    }

    /**
     * 场景 2: 多规则匹配
     */
    private func testMultipleRulesMatching() {
        println("🧪 场景 2: 多规则匹配")

        triggeredRules.clear()

        let engine = RuleEngine()

        engine.addRule(
            RuleBuilder("金额折扣")
                .salience(100)
                .when("amount", ">", PropertyValue(1000.0))
                .then({ triggeredRules.add("金额折扣") })
                .build()
        )

        engine.addRule(
            RuleBuilder("商品数折扣")
                .salience(90)
                .when("items", ">", PropertyValue(10))
                .then({ triggeredRules.add("商品数折扣") })
                .build()
        )

        // 插入同时满足两个条件的订单
        engine.insert(OrderFact("ORDER-002", "普通", 1500.0, 12))
        engine.fireAllRules()

        assert(triggeredRules.contains("金额折扣"), "应触发金额折扣")
        assert(triggeredRules.contains("商品数折扣"), "应触发商品数折扣")
        assertEquals(2, triggeredRules.size, "应触发 2 条规则")

        println("")
    }

    /**
     * 场景 3: 规则优先级
     */
    private func testRulePriority() {
        println("🧪 场景 3: 规则优先级")

        triggeredRules.clear()

        let engine = RuleEngine()

        engine.addRule(
            RuleBuilder("低优先级规则")
                .salience(50)
                .when("amount", ">", PropertyValue(500.0))
                .then({ triggeredRules.add("低优先级规则") })
                .build()
        )

        engine.addRule(
            RuleBuilder("高优先级规则")
                .salience(100)
                .when("amount", ">", PropertyValue(500.0))
                .then({ triggeredRules.add("高优先级规则") })
                .build()
        )

        engine.insert(OrderFact("ORDER-003", "普通", 1000.0, 5))
        engine.fireAllRules()

        // 高优先级规则应先执行
        assertEquals("高优先级规则", triggeredRules[0], "高优先级规则应先执行")

        println("")
    }

    /**
     * 场景 4: VIP 客户折扣
     */
    private func testVIPCustomerDiscount() {
        println("🧪 场景 4: VIP 客户专属折扣")

        triggeredRules.clear()

        let engine = RuleEngine()

        engine.addRule(
            RuleBuilder("VIP专属折扣")
                .salience(100)
                .when("customer", "=", PropertyValue("VIP"))
                .then({ triggeredRules.add("VIP专属折扣") })
                .build()
        )

        engine.addRule(
            RuleBuilder("普通客户折扣")
                .salience(50)
                .when("customer", "=", PropertyValue("普通"))
                .then({ triggeredRules.add("普通客户折扣") })
                .build()
        )

        // VIP 订单
        engine.insert(OrderFact("ORDER-004", "VIP", 800.0, 5))
        engine.fireAllRules()

        assert(triggeredRules.contains("VIP专属折扣"), "VIP 客户应触发 VIP 折扣")
        assert(!triggeredRules.contains("普通客户折扣"), "VIP 客户不应触发普通折扣")

        println("")
    }

    /**
     * 场景 5: 复杂场景 - 多条件多规则
     */
    private func testComplexScenario() {
        println("🧪 场景 5: 复杂场景")

        triggeredRules.clear()

        let engine = RuleEngine()

        // 定义规则
        engine.addRule(
            RuleBuilder("规则1: 金额>1000")
                .salience(100)
                .when("amount", ">", PropertyValue(1000.0))
                .then({ triggeredRules.add("规则1") })
                .build()
        )

        engine.addRule(
            RuleBuilder("规则2: 商品数>10")
                .salience(90)
                .when("items", ">", PropertyValue(10))
                .then({ triggeredRules.add("规则2") })
                .build()
        )

        engine.addRule(
            RuleBuilder("规则3: VIP客户")
                .salience(80)
                .when("customer", "=", PropertyValue("VIP"))
                .then({ triggeredRules.add("规则3") })
                .build()
        )

        // 插入多个订单
        engine.insert(OrderFact("ORDER-005", "普通", 1200.0, 5))    // 匹配规则1
        engine.insert(OrderFact("ORDER-006", "VIP", 800.0, 15))      // 匹配规则2和3
        engine.insert(OrderFact("ORDER-007", "普通", 1500.0, 12))  // 匹配规则1和2

        engine.fireAllRules()

        assert(triggeredRules.size >= 3, "应触发至少 3 条规则")

        println("  触发的规则: ${triggeredRules}")

        println("")
    }

    /**
     * 场景 6: 无匹配场景
     */
    private func testNoMatchScenario() {
        println("🧪 场景 6: 无匹配场景")

        triggeredRules.clear()

        let engine = RuleEngine()

        engine.addRule(
            RuleBuilder("高金额折扣")
                .salience(100)
                .when("amount", ">", PropertyValue(5000.0))
                .then({ triggeredRules.add("高金额折扣") })
                .build()
        )

        // 插入不满足条件的订单
        engine.insert(OrderFact("ORDER-008", "普通", 500.0, 2))
        engine.fireAllRules()

        assertEquals(0, triggeredRules.size, "不应触发任何规则")

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

main() {
    let test = DiscountRulesIntegrationTest()
    let success = test.runAll()

    if (success) {
        println("\n🎉 所有集成测试通过!")
        System.exit(0)
    } else {
        println("\n⚠️ 存在失败的测试!")
        System.exit(1)
    }
}
