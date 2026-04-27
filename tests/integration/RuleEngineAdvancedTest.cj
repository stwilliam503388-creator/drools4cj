/*
 * Drools4Cj - 集成测试
 * 文件: RuleEngineAdvancedTest.cj
 * 说明: 测试 RuleEngine 的高级功能:update/retract、maxFacts、noLoop、
 *       禁用规则、自定义监听器、RuleEngineBuilder、多条件规则
 */

package tests.integration

import core.*
import core.RuleEngine
import core.RuleEngineConfig
import core.RuleEngineBuilder
import core.RuleBuilder
import core.Rule
import core.OrderFact
import core.ProductFact
import core.CustomerFact
import core.PropertyValue
import core.RuleListener
import core.Fact
import std.collection.ArrayList

/**
 * 用于测试的自定义规则监听器
 * 记录所有监听器回调以便断言
 */
class TestRuleListener : RuleListener {
    public var matchEvents: ArrayList<String> = ArrayList()
    public var beforeEvents: ArrayList<String> = ArrayList()
    public var afterEvents: ArrayList<String> = ArrayList()

    public init() {}

    public func onMatch(rule: Rule, fact: Fact) {
        matchEvents.add("match:${rule.name}")
    }

    public func onBeforeExecute(rule: Rule, fact: Fact) {
        beforeEvents.add("before:${rule.name}")
    }

    public func onAfterExecute(rule: Rule, fact: Fact) {
        afterEvents.add("after:${rule.name}")
    }
}

/**
 * RuleEngine 高级集成测试
 */
class RuleEngineAdvancedTest {
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
        println("║      RuleEngine 高级集成测试                         ║")
        println("╚══════════════════════════════════════════════════════╝\n")

        testUpdateFactStats()
        testUpdateFactTriggersReevaluation()
        testRetractFactStats()
        testRetractFactPreventsRuleFire()
        testRetractNonExistentFact()
        testMaxFactsLimit()
        testMaxFactsLimitCustomConfig()
        testNoLoopRuleFiresOnce()
        testDisabledRuleNotFired()
        testRuleEngineBuilderDefault()
        testRuleEngineBuilderCustomConfig()
        testMultipleConditionsRule()
        testCustomListenerReceivesCallbacks()
        testEngineStatsAccumulation()
        testEngineGetAgenda()
        testInsertMultipleFacts()
        testUpdateAndFireRules()
        testRetractAndFireRules()

        printResults()
        return failed == 0
    }

    // ==================== update 测试 ====================

    /**
     * 测试 update - 统计信息更新
     */
    private func testUpdateFactStats() {
        println("🧪 测试: RuleEngine update - 统计信息")

        let engine = RuleEngine()

        engine.addRule(
            RuleBuilder("金额规则")
                .when("amount", ">", PropertyValue(1000.0))
                .then({ })
                .build()
        )

        engine.insert(OrderFact("O001", "普通", 500.0, 3))
        let stats = engine.getStats()
        assertEquals(1, stats.totalFactsInserted, "插入后统计应为 1")
        assertEquals(0, stats.totalFactsUpdated, "更新前统计应为 0")

        engine.update(OrderFact("O001", "VIP", 2000.0, 5))
        let updatedStats = engine.getStats()
        assertEquals(1, updatedStats.totalFactsUpdated, "更新后统计应为 1")

        println("")
    }

    /**
     * 测试 update - 触发规则重新评估
     */
    private func testUpdateFactTriggersReevaluation() {
        println("🧪 测试: RuleEngine update - 触发规则重新评估")

        let engine = RuleEngine()
        var ruleFireCount = 0

        engine.addRule(
            RuleBuilder("高金额规则")
                .when("amount", ">", PropertyValue(1000.0))
                .then({ ruleFireCount++ })
                .build()
        )

        // 插入不满足条件的事实
        engine.insert(OrderFact("O001", "普通", 500.0, 3))

        // 更新为满足条件的事实
        let updateSuccess = engine.update(OrderFact("O001", "普通", 2000.0, 3))
        assert(updateSuccess, "更新已存在的事实应返回 true")

        // 执行规则,应触发
        engine.fireAllRules()
        assert(ruleFireCount > 0, "更新后满足条件的事实应触发规则")

        println("")
    }

    // ==================== retract 测试 ====================

    /**
     * 测试 retract - 统计信息更新
     */
    private func testRetractFactStats() {
        println("🧪 测试: RuleEngine retract - 统计信息")

        let engine = RuleEngine()

        engine.insert(OrderFact("O001", "普通", 500.0, 3))
        assertEquals(0, engine.getStats().totalFactsRetracted, "撤回前统计应为 0")

        engine.retract("O001")
        assertEquals(1, engine.getStats().totalFactsRetracted, "撤回后统计应为 1")

        println("")
    }

    /**
     * 测试 retract - 撤回后规则不触发
     */
    private func testRetractFactPreventsRuleFire() {
        println("🧪 测试: RuleEngine retract - 撤回后规则不触发")

        let engine = RuleEngine()
        var ruleExecuted = false

        engine.addRule(
            RuleBuilder("金额规则")
                .when("amount", ">", PropertyValue(500.0))
                .then({ ruleExecuted = true })
                .build()
        )

        // 插入满足条件的事实
        engine.insert(OrderFact("O001", "普通", 1000.0, 3))

        // 撤回该事实
        let success = engine.retract("O001")
        assert(success, "撤回已存在的事实应返回 true")
        assertEquals(0, engine.getWorkingMemory().getSize(), "撤回后工作内存应为空")

        // 执行规则,不应触发
        engine.fireAllRules()
        assert(!ruleExecuted, "撤回事实后规则不应被触发")

        println("")
    }

    /**
     * 测试 retract - 撤回不存在事实返回 false
     */
    private func testRetractNonExistentFact() {
        println("🧪 测试: RuleEngine retract - 撤回不存在事实")

        let engine = RuleEngine()

        let success = engine.retract("NOT-EXIST")
        assert(!success, "撤回不存在的事实应返回 false")
        assertEquals(0, engine.getStats().totalFactsRetracted, "失败的撤回不应计入统计")

        println("")
    }

    // ==================== maxFacts 测试 ====================

    /**
     * 测试 maxFacts - 超限时插入返回 -1
     */
    private func testMaxFactsLimit() {
        println("🧪 测试: RuleEngine maxFacts - 超限处理")

        let config = RuleEngineConfig()
        config.maxFacts = 3
        config.enableLog = false
        let engine = RuleEngine(config)

        let v1 = engine.insert(OrderFact("O001", "普通", 100.0, 1))
        let v2 = engine.insert(OrderFact("O002", "普通", 200.0, 2))
        let v3 = engine.insert(OrderFact("O003", "普通", 300.0, 3))

        assert(v1 > 0, "第 1 次插入应成功")
        assert(v2 > 0, "第 2 次插入应成功")
        assert(v3 > 0, "第 3 次插入应成功")
        assertEquals(3, engine.getWorkingMemory().getSize(), "达到上限后工作内存应有 3 个事实")

        // 超出限制
        let v4 = engine.insert(OrderFact("O004", "普通", 400.0, 4))
        assertEquals(-1, v4, "超出 maxFacts 限制的插入应返回 -1")
        assertEquals(3, engine.getWorkingMemory().getSize(), "拒绝插入后工作内存大小应仍为 3")

        println("")
    }

    /**
     * 测试 maxFacts - RuleEngineBuilder 自定义上限
     */
    private func testMaxFactsLimitCustomConfig() {
        println("🧪 测试: RuleEngine maxFacts - 自定义上限配置")

        let engine = RuleEngineBuilder()
            .enableLog(false)
            .maxFacts(2)
            .build()

        engine.insert(OrderFact("O001", "普通", 100.0, 1))
        engine.insert(OrderFact("O002", "普通", 200.0, 2))

        assertEquals(2, engine.getWorkingMemory().getSize(), "应有 2 个事实")

        let overLimit = engine.insert(OrderFact("O003", "普通", 300.0, 3))
        assertEquals(-1, overLimit, "超出自定义 maxFacts 限制应返回 -1")
        assertEquals(2, engine.getStats().totalFactsInserted, "被拒绝的插入不计入统计")

        println("")
    }

    // ==================== noLoop 测试 ====================

    /**
     * 测试 noLoop 规则只触发一次
     */
    private func testNoLoopRuleFiresOnce() {
        println("🧪 测试: noLoop 规则只触发一次")

        let engine = RuleEngine()
        var fireCount = 0

        engine.addRule(
            RuleBuilder("NoLoop规则")
                .salience(100)
                .noLoop(true)
                .when("amount", ">", PropertyValue(500.0))
                .then({ fireCount++ })
                .build()
        )

        // 插入多个满足条件的事实
        engine.insert(OrderFact("O001", "普通", 1000.0, 3))

        // 执行规则
        engine.fireAllRules()
        let countAfterFirst = fireCount

        // 再次执行,noLoop 规则不应重复触发(已在 agenda 的 firedRules 中)
        engine.fireAllRules()

        // noLoop 防止议程中同名规则重复激活
        assert(countAfterFirst > 0, "noLoop 规则首次执行应被触发")
        assert(fireCount == countAfterFirst, "noLoop 规则在同一会话中不应被重复触发")

        println("")
    }

    // ==================== 禁用规则测试 ====================

    /**
     * 测试 禁用规则不触发
     */
    private func testDisabledRuleNotFired() {
        println("🧪 测试: 禁用规则不被触发")

        let engine = RuleEngine()
        var rule1Executed = false
        var rule2Executed = false

        let rule1 = RuleBuilder("启用规则")
            .when("amount", ">", PropertyValue(500.0))
            .then({ rule1Executed = true })
            .build()

        let rule2 = RuleBuilder("禁用规则")
            .when("amount", ">", PropertyValue(500.0))
            .then({ rule2Executed = true })
            .build()
        rule2.setEnabled(false)

        engine.addRule(rule1)
        engine.addRule(rule2)

        engine.insert(OrderFact("O001", "普通", 1000.0, 5))
        engine.fireAllRules()

        assert(rule1Executed, "启用规则应被触发")
        assert(!rule2Executed, "禁用规则不应被触发")

        println("")
    }

    // ==================== RuleEngineBuilder 测试 ====================

    /**
     * 测试 RuleEngineBuilder 默认配置构建
     */
    private func testRuleEngineBuilderDefault() {
        println("🧪 测试: RuleEngineBuilder 默认配置")

        let engine = RuleEngineBuilder().build()

        assert(engine != None, "RuleEngineBuilder 应能构建引擎")
        assertEquals(0, engine.getRules().size, "新引擎默认无规则")
        assertEquals(0, engine.getWorkingMemory().getSize(), "新引擎工作内存应为空")

        println("")
    }

    /**
     * 测试 RuleEngineBuilder 自定义配置
     */
    private func testRuleEngineBuilderCustomConfig() {
        println("🧪 测试: RuleEngineBuilder 自定义配置")

        let engine = RuleEngineBuilder()
            .enableLog(false)
            .enableStats(true)
            .maxFacts(500)
            .build()

        // 验证 maxFacts 生效(插入 500 条后第 501 条应失败)
        for (i in 0..500) {
            engine.insert(OrderFact("O${i}", "普通", 100.0, 1))
        }

        assertEquals(500, engine.getWorkingMemory().getSize(), "应达到 500 条事实上限")

        let overLimit = engine.insert(OrderFact("O500", "普通", 100.0, 1))
        assertEquals(-1, overLimit, "超出 maxFacts=500 限制应返回 -1")

        println("")
    }

    // ==================== 多条件规则测试 ====================

    /**
     * 测试 多条件规则 AND 逻辑集成
     */
    private func testMultipleConditionsRule() {
        println("🧪 测试: 多条件规则 AND 逻辑集成测试")

        let engine = RuleEngine()
        var triggeredFacts = ArrayList<String>()

        // 规则需要同时满足:金额 > 1000 AND 客户 = VIP
        engine.addRule(
            RuleBuilder("VIP高金额规则")
                .salience(100)
                .when("amount", ">", PropertyValue(1000.0))
                .when("customer", "=", PropertyValue("VIP"))
                .then({ triggeredFacts.add("VIP高金额规则触发") })
                .build()
        )

        // 只满足金额条件
        engine.insert(OrderFact("O001", "普通", 1500.0, 5))
        // 只满足客户条件
        engine.insert(OrderFact("O002", "VIP", 500.0, 3))
        // 同时满足两个条件
        engine.insert(OrderFact("O003", "VIP", 2000.0, 8))

        engine.fireAllRules()

        // 只有 O003 同时满足两个条件
        assertEquals(1, triggeredFacts.size, "只有同时满足两个条件的事实才应触发规则")

        println("")
    }

    // ==================== 自定义监听器测试 ====================

    /**
     * 测试 自定义监听器接收回调
     */
    private func testCustomListenerReceivesCallbacks() {
        println("🧪 测试: 自定义监听器接收回调")

        let engine = RuleEngine()
        let listener = TestRuleListener()
        engine.setListener(listener)

        engine.addRule(
            RuleBuilder("监听测试规则")
                .when("amount", ">", PropertyValue(500.0))
                .then({ })
                .build()
        )

        engine.insert(OrderFact("O001", "普通", 1000.0, 3))
        engine.fireAllRules()

        // 验证监听器收到了匹配事件
        assert(listener.matchEvents.size > 0, "自定义监听器应收到 onMatch 事件")
        // 验证监听器收到了执行前事件
        assert(listener.beforeEvents.size > 0, "自定义监听器应收到 onBeforeExecute 事件")
        // 验证监听器收到了执行后事件
        assert(listener.afterEvents.size > 0, "自定义监听器应收到 onAfterExecute 事件")

        // 验证事件内容
        assert(listener.matchEvents[0].contains("监听测试规则"), "匹配事件应包含规则名称")

        println("")
    }

    // ==================== 统计信息测试 ====================

    /**
     * 测试 引擎统计信息累积
     */
    private func testEngineStatsAccumulation() {
        println("🧪 测试: 引擎统计信息累积")

        let engine = RuleEngine()

        engine.addRule(
            RuleBuilder("统计规则")
                .when("amount", ">", PropertyValue(100.0))
                .then({ })
                .build()
        )

        // 插入
        engine.insert(OrderFact("O001", "普通", 500.0, 3))
        engine.insert(OrderFact("O002", "VIP", 1000.0, 5))
        assertEquals(2, engine.getStats().totalFactsInserted, "插入 2 个后统计应为 2")

        // 更新
        engine.update(OrderFact("O001", "VIP", 800.0, 4))
        assertEquals(1, engine.getStats().totalFactsUpdated, "更新 1 个后统计应为 1")

        // 撤回
        engine.retract("O002")
        assertEquals(1, engine.getStats().totalFactsRetracted, "撤回 1 个后统计应为 1")

        // 执行规则
        engine.fireAllRules()
        assert(engine.getStats().totalRulesExecuted > 0, "执行规则后统计应大于 0")
        assert(engine.getStats().totalMatches > 0, "应有匹配次数统计")

        println("")
    }

    /**
     * 测试 getAgenda - 获取议程
     */
    private func testEngineGetAgenda() {
        println("🧪 测试: RuleEngine getAgenda")

        let engine = RuleEngine()

        engine.addRule(
            RuleBuilder("议程测试规则")
                .when("amount", ">", PropertyValue(100.0))
                .then({ })
                .build()
        )

        // 插入满足条件的事实(会填充议程)
        engine.insert(OrderFact("O001", "普通", 500.0, 3))

        let agenda = engine.getAgenda()
        assert(agenda.getPendingCount() > 0, "插入事实后议程应有待触发的激活")

        println("")
    }

    /**
     * 测试 insert - 多个事实插入
     */
    private func testInsertMultipleFacts() {
        println("🧪 测试: RuleEngine insert - 多个不同类型事实")

        let engine = RuleEngine()

        engine.addRule(
            RuleBuilder("混合事实规则")
                .when("amount", ">", PropertyValue(500.0))
                .then({ })
                .build()
        )

        engine.insert(OrderFact("O001", "普通", 1000.0, 3))
        engine.insert(ProductFact("P001", "商品A", 200.0, 10))
        engine.insert(CustomerFact("C001", "张三", "金卡", 5000, 20))

        assertEquals(3, engine.getWorkingMemory().getSize(), "应有 3 个不同类型事实")
        assertEquals(3, engine.getStats().totalFactsInserted, "插入统计应为 3")

        println("")
    }

    /**
     * 测试 update 后重新执行规则
     */
    private func testUpdateAndFireRules() {
        println("🧪 测试: RuleEngine update 后重新执行规则场景")

        let engine = RuleEngine()
        var executedForLow = false
        var executedForHigh = false

        engine.addRule(
            RuleBuilder("低金额规则")
                .when("amount", "<", PropertyValue(1000.0))
                .then({ executedForLow = true })
                .build()
        )

        engine.addRule(
            RuleBuilder("高金额规则")
                .when("amount", ">", PropertyValue(1000.0))
                .then({ executedForHigh = true })
                .build()
        )

        // 插入低金额事实
        engine.insert(OrderFact("O001", "普通", 500.0, 3))

        // 更新为高金额事实
        engine.update(OrderFact("O001", "普通", 2000.0, 3))

        // 执行规则
        engine.fireAllRules()

        // 更新触发了 reevaluateRules,议程中应有高金额规则
        assert(executedForHigh, "更新后高金额规则应被触发")

        println("")
    }

    /**
     * 测试 retract 后执行规则
     */
    private func testRetractAndFireRules() {
        println("🧪 测试: RuleEngine retract 后执行规则场景")

        let engine = RuleEngine()
        var ruleExecuted = false

        engine.addRule(
            RuleBuilder("存在规则")
                .when("amount", ">", PropertyValue(500.0))
                .then({ ruleExecuted = true })
                .build()
        )

        engine.insert(OrderFact("O001", "普通", 1000.0, 3))
        engine.insert(OrderFact("O002", "VIP", 2000.0, 5))

        // 撤回所有事实
        engine.retract("O001")
        engine.retract("O002")

        assertEquals(0, engine.getWorkingMemory().getSize(), "撤回后工作内存应为空")

        // 执行规则,不应触发
        engine.fireAllRules()
        assert(!ruleExecuted, "撤回所有事实后规则不应被触发")

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
 * 主函数 - 运行 RuleEngine 高级集成测试
 */
main() {
    let test = RuleEngineAdvancedTest()
    let success = test.runAll()

    if (success) {
        println("\n🎉 所有集成测试通过!")
        System.exit(0)
    } else {
        println("\n⚠️ 存在失败的测试!")
        System.exit(1)
    }
}
