/*
 * Drools4Cj - 单元测试
 * 文件: RuleEngineTest.cj
 * 说明: 测试 RuleEngine 类
 */

package tests.unit

import core.*
import core.RuleEngine
import core.RuleEngineBuilder
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
        testUpdateFact()
        testRetractFact()
        testRuleEngineBuilder()
        testMaxFactsLimit()

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

    /**
     * 测试更新事实
     */
    private func testUpdateFact() {
        println("🧪 测试: 更新事实")

        let engine = RuleEngine()

        engine.addRule(
            RuleBuilder("VIP规则")
                .when("customer", "=", PropertyValue("VIP"))
                .then({ })
                .build()
        )

        engine.insert(OrderFact("ORDER-001", "普通", 1000.0, 3))
        assertEquals(1, engine.getWorkingMemory().getSize(), "插入后应有 1 个事实")

        // 更新事实
        let success = engine.update(OrderFact("ORDER-001", "VIP", 2000.0, 8))
        assert(success, "更新应成功")
        assertEquals(1, engine.getWorkingMemory().getSize(), "更新后事实数量不变")

        let updateStats = engine.getStats()
        assertEquals(1, updateStats.totalFactsUpdated, "更新统计应为 1")

        // 更新不存在的事实应失败
        let failSuccess = engine.update(OrderFact("NON-EXISTENT", "普通", 100.0, 1))
        assert(!failSuccess, "更新不存在的事实应失败")

        println("")
    }

    /**
     * 测试撤回事实
     */
    private func testRetractFact() {
        println("🧪 测试: 撤回事实")

        let engine = RuleEngine()

        engine.insert(OrderFact("ORDER-001", "普通", 1000.0, 3))
        engine.insert(OrderFact("ORDER-002", "VIP", 2000.0, 8))
        assertEquals(2, engine.getWorkingMemory().getSize(), "插入后应有 2 个事实")

        // 撤回一个事实
        let success = engine.retract("ORDER-001")
        assert(success, "撤回应成功")
        assertEquals(1, engine.getWorkingMemory().getSize(), "撤回后应剩 1 个事实")

        let retractStats = engine.getStats()
        assertEquals(1, retractStats.totalFactsRetracted, "撤回统计应为 1")

        // 撤回不存在的事实应失败
        let failSuccess = engine.retract("NON-EXISTENT")
        assert(!failSuccess, "撤回不存在的事实应失败")

        println("")
    }

    /**
     * 测试 RuleEngineBuilder
     */
    private func testRuleEngineBuilder() {
        println("🧪 测试: RuleEngineBuilder")

        // 测试构建器能构建有效的引擎
        let engine = RuleEngineBuilder()
            .enableLog(false)
            .enableStats(true)
            .maxFacts(500)
            .build()

        // 引擎应正常工作
        engine.addRule(
            RuleBuilder("测试规则")
                .when("amount", ">", PropertyValue(100.0))
                .then({ })
                .build()
        )
        assertEquals(1, engine.getRules().size, "引擎应有 1 条规则")

        let version = engine.insert(OrderFact("ORDER-001", "普通", 500.0, 3))
        assert(version > 0, "插入应返回正版本号")
        assertEquals(1, engine.getWorkingMemory().getSize(), "工作内存应有 1 个事实")

        println("")
    }

    /**
     * 测试最大事实数限制
     */
    private func testMaxFactsLimit() {
        println("🧪 测试: 最大事实数限制")

        // 创建最多允许 2 个事实的引擎
        let engine = RuleEngineBuilder()
            .enableLog(false)
            .maxFacts(2)
            .build()

        let v1 = engine.insert(OrderFact("ORDER-001", "普通", 1000.0, 3))
        let v2 = engine.insert(OrderFact("ORDER-002", "VIP", 2000.0, 5))

        assert(v1 > 0, "第 1 次插入应成功")
        assert(v2 > 0, "第 2 次插入应成功")
        assertEquals(2, engine.getWorkingMemory().getSize(), "应有 2 个事实")

        // 第 3 次插入应被拒绝
        let v3 = engine.insert(OrderFact("ORDER-003", "普通", 500.0, 2))
        assertEquals(-1, v3, "超过最大事实数时插入应返回 -1")
        assertEquals(2, engine.getWorkingMemory().getSize(), "事实数不应超过最大值")

        println("")
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
