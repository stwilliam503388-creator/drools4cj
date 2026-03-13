/*
 * Drools4Cj - 单元测试
 * 文件: RuleEngineTest.cj
 * 说明: 测试 RuleEngine 类
 */

package tests.unit

import std.collection.ArrayList
import core.*
import core.RuleEngine
import core.RuleBuilder
import core.OrderFact
import core.PropertyValue

/**
 * RuleEngine 类单元测试
 */
class RuleEngineTest {
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
        println("║      RuleEngine 类单元测试                            ║")
        println("╚══════════════════════════════════════════════════════╝\n")

        testAddRule()
        testRemoveRule()
        testInsertFact()
        testFireAllRules()
        testReset()
        testStats()

        printResults()
        return failed == 0
    }

    /**
     * 测试添加规则
     */
    private func testAddRule() {
        println("🧪 测试: 添加规则")

        let engine = RuleEngine()

        engine.addRule(
            RuleBuilder("测试规则")
                .salience(100)
                .when("amount", ">", PropertyValue(1000.0))
                .then({ })
                .build()
        )

        assertEquals(1, engine.getRules().size, "应有 1 条规则")

        let rule = engine.getRules()[0]
        assertEquals("测试规则", rule.name, "规则名称应正确")
        assertEquals(100, rule.salience, "规则优先级应为 100")

        println("")
    }

    /**
     * 测试移除规则
     */
    private func testRemoveRule() {
        println("🧪 测试: 移除规则")

        let engine = RuleEngine()

        engine.addRule(
            RuleBuilder("规则1")
                .salience(50)
                .when("amount", ">", PropertyValue(500.0))
                .then({ })
                .build()
        )

        engine.addRule(
            RuleBuilder("规则2")
                .salience(100)
                .when("items", ">", PropertyValue(5))
                .then({ })
                .build()
        )

        assertEquals(2, engine.getRules().size, "应有 2 条规则")

        let success = engine.removeRule("规则1")
        assert(success, "移除应成功")
        assertEquals(1, engine.getRules().size, "移除后应有 1 条规则")

        let fail = engine.removeRule("不存在的规则")
        assert(!fail, "移除不存在的规则应失败")

        println("")
    }

    /**
     * 测试插入事实
     */
    private func testInsertFact() {
        println("🧪 测试: 插入事实")

        let engine = RuleEngine()

        engine.addRule(
            RuleBuilder("测试规则")
                .when("amount", ">", PropertyValue(1000.0))
                .then({ })
                .build()
        )

        let version = engine.insert(OrderFact("ORDER-001", "普通", 1200.0, 5))
        assert(version > 0, "插入应返回正版本号")

        let wm = engine.getWorkingMemory()
        assertEquals(1, wm.getSize(), "工作内存应有 1 个事实")

        println("")
    }

    /**
     * 测试执行规则
     */
    private func testFireAllRules() {
        println("🧪 测试: 执行所有规则")

        let engine = RuleEngine()

        var ruleExecuted = false

        engine.addRule(
            RuleBuilder("测试规则")
                .salience(100)
                .when("amount", ">", PropertyValue(1000.0))
                .then({
                    ruleExecuted = true
                })
                .build()
        )

        engine.insert(OrderFact("ORDER-001", "普通", 1200.0, 5))
        engine.fireAllRules()

        assert(ruleExecuted, "规则应被执行")

        let stats = engine.getStats()
        assert(stats.totalRulesExecuted > 0, "统计应显示执行的规则数")

        println("")
    }

    /**
     * 测试重置引擎
     */
    private func testReset() {
        println("🧪 测试: 重置引擎")

        let engine = RuleEngine()

        engine.addRule(
            RuleBuilder("测试规则")
                .when("amount", ">", PropertyValue(1000.0))
                .then({ })
                .build()
        )

        engine.insert(OrderFact("ORDER-001", "普通", 1200.0, 5))

        assert(engine.getWorkingMemory().getSize() > 0, "重置前应有事实")

        engine.reset()

        assertEquals(0, engine.getWorkingMemory().getSize(), "重置后工作内存应为空")

        let stats = engine.getStats()
        assertEquals(0, stats.totalFactsInserted, "重置后统计应清零")

        println("")
    }

    /**
     * 测试统计信息
     */
    private func testStats() {
        println("🧪 测试: 统计信息")

        let engine = RuleEngine()

        engine.addRule(
            RuleBuilder("测试规则")
                .when("amount", ">", PropertyValue(1000.0))
                .then({ })
                .build()
        )

        engine.insert(OrderFact("ORDER-001", "普通", 1200.0, 5))
        engine.insert(OrderFact("ORDER-002", "VIP", 2000.0, 8))

        engine.fireAllRules()

        let stats = engine.getStats()
        assertEquals(2, stats.totalFactsInserted, "应插入 2 个事实")
        assert(stats.totalMatches > 0, "应有匹配次数")
        assert(stats.totalRulesExecuted > 0, "应执行规则")

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
    let test = RuleEngineTest()
    let success = test.runAll()

    if (success) {
        println("\n🎉 所有测试通过!")
        System.exit(0)
    } else {
        println("\n⚠️ 存在失败的测试!")
        System.exit(1)
    }
}
