/*
 * Drools4Cj - 单元测试
 * 文件: AgendaTest.cj
 * 说明: 测试 PatternMatcher 和 Agenda 类
 */

package tests.unit

import core.*
import core.WorkingMemory
import core.PatternMatcher
import core.Agenda
import core.Rule
import core.RuleBuilder
import core.OrderFact
import core.ProductFact
import core.Fact
import core.PropertyValue

/**
 * PatternMatcher 和 Agenda 单元测试
 */
class AgendaTest {
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
        println("║      PatternMatcher 和 Agenda 单元测试               ║")
        println("╚══════════════════════════════════════════════════════╝\n")

        testPatternMatcherMatchRules()
        testPatternMatcherMatchRulesWithDisabledRule()
        testPatternMatcherMatchRulesEmptyWorkingMemory()
        testPatternMatcherIncrementalMatchSingleRule()
        testPatternMatcherIncrementalMatchMultipleRules()
        testPatternMatcherGetMatchCount()
        testPatternMatcherReset()
        testAgendaAddActivation()
        testAgendaPendingCount()
        testAgendaFireNext()
        testAgendaFireNextEmpty()
        testAgendaFireAll()
        testAgendaFireAllWithPriority()
        testAgendaClear()
        testAgendaNoLoop()
        testAgendaIsRuleFired()
        testAgendaGetFiredCount()

        printResults()
        return failed == 0
    }

    // ==================== PatternMatcher 测试 ====================

    /**
     * 测试 PatternMatcher.matchRules() - 基本匹配
     */
    private func testPatternMatcherMatchRules() {
        println("🧪 测试: PatternMatcher.matchRules() - 基本匹配")

        let wm = WorkingMemory()
        wm.insert(OrderFact("ORDER-001", "普通", 1200.0, 5))
        wm.insert(OrderFact("ORDER-002", "VIP", 800.0, 3))

        let matcher = PatternMatcher(wm)
        let rules = ArrayList<Rule>()

        rules.add(
            RuleBuilder("金额规则")
                .when("amount", ">", PropertyValue(1000.0))
                .then({ })
                .build()
        )

        let matches = matcher.matchRules(rules)
        // ORDER-001(1200 > 1000) 应匹配, ORDER-002(800 > 1000) 不匹配
        assertEquals(1, matches.size, "应匹配 1 个事实(金额 > 1000)")

        println("")
    }

    /**
     * 测试 PatternMatcher.matchRules() - 跳过禁用规则
     */
    private func testPatternMatcherMatchRulesWithDisabledRule() {
        println("🧪 测试: PatternMatcher.matchRules() - 跳过禁用规则")

        let wm = WorkingMemory()
        wm.insert(OrderFact("ORDER-001", "普通", 1200.0, 5))

        let matcher = PatternMatcher(wm)
        let rules = ArrayList<Rule>()

        let rule = RuleBuilder("禁用规则")
            .when("amount", ">", PropertyValue(1000.0))
            .then({ })
            .build()
        rule.setEnabled(false)
        rules.add(rule)

        let matches = matcher.matchRules(rules)
        assertEquals(0, matches.size, "禁用规则不应产生匹配")

        println("")
    }

    /**
     * 测试 PatternMatcher.matchRules() - 工作内存为空时不匹配
     */
    private func testPatternMatcherMatchRulesEmptyWorkingMemory() {
        println("🧪 测试: PatternMatcher.matchRules() - 工作内存为空")

        let wm = WorkingMemory()
        let matcher = PatternMatcher(wm)
        let rules = ArrayList<Rule>()

        rules.add(
            RuleBuilder("金额规则")
                .when("amount", ">", PropertyValue(1000.0))
                .then({ })
                .build()
        )

        let matches = matcher.matchRules(rules)
        assertEquals(0, matches.size, "工作内存为空时不应有匹配")

        println("")
    }

    /**
     * 测试 PatternMatcher.incrementalMatch() - 单规则匹配
     */
    private func testPatternMatcherIncrementalMatchSingleRule() {
        println("🧪 测试: PatternMatcher.incrementalMatch() - 单规则")

        let wm = WorkingMemory()
        let matcher = PatternMatcher(wm)
        let rules = ArrayList<Rule>()

        rules.add(
            RuleBuilder("金额规则")
                .when("amount", ">", PropertyValue(1000.0))
                .then({ })
                .build()
        )

        // 匹配满足条件的事实
        let matchingFact = OrderFact("ORDER-001", "普通", 1500.0, 5)
        let matches1 = matcher.incrementalMatch(rules, matchingFact)
        assertEquals(1, matches1.size, "满足条件的事实应匹配 1 条规则")

        // 不匹配不满足条件的事实
        let nonMatchingFact = OrderFact("ORDER-002", "普通", 500.0, 5)
        let matches2 = matcher.incrementalMatch(rules, nonMatchingFact)
        assertEquals(0, matches2.size, "不满足条件的事实不应匹配")

        println("")
    }

    /**
     * 测试 PatternMatcher.incrementalMatch() - 多规则匹配
     */
    private func testPatternMatcherIncrementalMatchMultipleRules() {
        println("🧪 测试: PatternMatcher.incrementalMatch() - 多规则")

        let wm = WorkingMemory()
        let matcher = PatternMatcher(wm)
        let rules = ArrayList<Rule>()

        rules.add(
            RuleBuilder("金额规则")
                .when("amount", ">", PropertyValue(1000.0))
                .then({ })
                .build()
        )
        rules.add(
            RuleBuilder("VIP规则")
                .when("customer", "=", PropertyValue("VIP"))
                .then({ })
                .build()
        )

        // 只满足金额规则
        let fact1 = OrderFact("ORDER-001", "普通", 1500.0, 5)
        let matches1 = matcher.incrementalMatch(rules, fact1)
        assertEquals(1, matches1.size, "只满足金额规则时应匹配 1 条规则")

        // 同时满足两条规则
        let fact2 = OrderFact("ORDER-002", "VIP", 1500.0, 5)
        let matches2 = matcher.incrementalMatch(rules, fact2)
        assertEquals(2, matches2.size, "同时满足两条规则时应匹配 2 条规则")

        println("")
    }

    /**
     * 测试 PatternMatcher.getMatchCount()
     */
    private func testPatternMatcherGetMatchCount() {
        println("🧪 测试: PatternMatcher.getMatchCount()")

        let wm = WorkingMemory()
        wm.insert(OrderFact("ORDER-001", "普通", 1200.0, 5))
        wm.insert(OrderFact("ORDER-002", "普通", 1500.0, 8))

        let matcher = PatternMatcher(wm)
        assertEquals(0, matcher.getMatchCount(), "初始匹配次数应为 0")

        let rules = ArrayList<Rule>()
        rules.add(
            RuleBuilder("金额规则")
                .when("amount", ">", PropertyValue(1000.0))
                .then({ })
                .build()
        )

        matcher.matchRules(rules)
        assert(matcher.getMatchCount() > 0, "执行匹配后次数应大于 0")
        assertEquals(2, matcher.getMatchCount(), "两个事实都满足条件,匹配次数应为 2")

        println("")
    }

    /**
     * 测试 PatternMatcher.reset()
     */
    private func testPatternMatcherReset() {
        println("🧪 测试: PatternMatcher.reset()")

        let wm = WorkingMemory()
        wm.insert(OrderFact("ORDER-001", "普通", 1200.0, 5))

        let matcher = PatternMatcher(wm)
        let rules = ArrayList<Rule>()
        rules.add(
            RuleBuilder("金额规则")
                .when("amount", ">", PropertyValue(1000.0))
                .then({ })
                .build()
        )

        matcher.matchRules(rules)
        assert(matcher.getMatchCount() > 0, "匹配后次数应大于 0")

        matcher.reset()
        assertEquals(0, matcher.getMatchCount(), "重置后匹配次数应为 0")

        println("")
    }

    // ==================== Agenda 测试 ====================

    /**
     * 测试 Agenda.addActivation()
     */
    private func testAgendaAddActivation() {
        println("🧪 测试: Agenda.addActivation()")

        let agenda = Agenda()
        assertEquals(0, agenda.getPendingCount(), "初始待触发数应为 0")

        let rule = Rule("测试规则", 100)
        let facts = ArrayList<Fact>()
        facts.add(OrderFact("ORDER-001", "普通", 1000.0, 3))

        agenda.addActivation(rule, facts)
        assertEquals(1, agenda.getPendingCount(), "添加激活后待触发数应为 1")

        agenda.addActivation(Rule("规则2", 50), facts)
        assertEquals(2, agenda.getPendingCount(), "再次添加后待触发数应为 2")

        println("")
    }

    /**
     * 测试 Agenda.getPendingCount()
     */
    private func testAgendaPendingCount() {
        println("🧪 测试: Agenda.getPendingCount()")

        let agenda = Agenda()
        let facts = ArrayList<Fact>()
        facts.add(OrderFact("ORDER-001", "普通", 1000.0, 3))

        assertEquals(0, agenda.getPendingCount(), "初始待触发数应为 0")

        agenda.addActivation(Rule("规则1", 100), facts)
        assertEquals(1, agenda.getPendingCount(), "添加1个后待触发数应为 1")

        agenda.addActivation(Rule("规则2", 50), facts)
        assertEquals(2, agenda.getPendingCount(), "添加2个后待触发数应为 2")

        agenda.addActivation(Rule("规则3", 75), facts)
        assertEquals(3, agenda.getPendingCount(), "添加3个后待触发数应为 3")

        println("")
    }

    /**
     * 测试 Agenda.fireNext()
     */
    private func testAgendaFireNext() {
        println("🧪 测试: Agenda.fireNext()")

        let agenda = Agenda()
        var executed = false

        let rule = Rule("测试规则", 100)
        rule.addAction({ executed = true })

        let facts = ArrayList<Fact>()
        facts.add(OrderFact("ORDER-001", "普通", 1000.0, 3))

        agenda.addActivation(rule, facts)
        assertEquals(1, agenda.getPendingCount(), "触发前待触发数应为 1")

        let fired = agenda.fireNext()
        assertEquals(1, fired, "应触发 1 条规则")
        assert(executed, "规则动作应已执行")
        assertEquals(0, agenda.getPendingCount(), "触发后待触发数应为 0")

        println("")
    }

    /**
     * 测试 Agenda.fireNext() - 议程为空时返回 0
     */
    private func testAgendaFireNextEmpty() {
        println("🧪 测试: Agenda.fireNext() - 议程为空时返回 0")

        let agenda = Agenda()
        let noFired = agenda.fireNext()
        assertEquals(0, noFired, "议程为空时 fireNext 应返回 0")

        println("")
    }

    /**
     * 测试 Agenda.fireAll() - 触发所有规则
     */
    private func testAgendaFireAll() {
        println("🧪 测试: Agenda.fireAll() - 触发所有规则")

        let agenda = Agenda()
        var count = 0

        let facts = ArrayList<Fact>()
        facts.add(OrderFact("ORDER-001", "普通", 1000.0, 3))

        let rule1 = Rule("规则1", 100)
        rule1.addAction({ count++ })

        let rule2 = Rule("规则2", 50)
        rule2.addAction({ count++ })

        let rule3 = Rule("规则3", 75)
        rule3.addAction({ count++ })

        agenda.addActivation(rule1, facts)
        agenda.addActivation(rule2, facts)
        agenda.addActivation(rule3, facts)

        let fired = agenda.fireAll(None)
        assertEquals(3, fired, "应触发 3 条规则")
        assertEquals(3, count, "动作应执行 3 次")
        assertEquals(0, agenda.getPendingCount(), "触发后待触发数应为 0")

        println("")
    }

    /**
     * 测试 Agenda.fireAll() - 高优先级规则先执行
     */
    private func testAgendaFireAllWithPriority() {
        println("🧪 测试: Agenda.fireAll() - 高优先级规则先执行")

        let agenda = Agenda()
        var executionOrder = ArrayList<String>()

        let facts = ArrayList<Fact>()
        facts.add(OrderFact("ORDER-001", "普通", 1000.0, 3))

        let lowRule = Rule("低优先级", 50)
        lowRule.addAction({ executionOrder.add("低优先级") })

        let highRule = Rule("高优先级", 100)
        highRule.addAction({ executionOrder.add("高优先级") })

        let midRule = Rule("中优先级", 75)
        midRule.addAction({ executionOrder.add("中优先级") })

        // 按低→中→高顺序添加,验证执行顺序按优先级排序
        agenda.addActivation(lowRule, facts)
        agenda.addActivation(midRule, facts)
        agenda.addActivation(highRule, facts)

        agenda.fireAll(None)

        assertEquals(3, executionOrder.size, "应触发 3 条规则")
        assertEquals("高优先级", executionOrder[0], "高优先级规则应最先执行")
        assertEquals("中优先级", executionOrder[1], "中优先级规则应第二执行")
        assertEquals("低优先级", executionOrder[2], "低优先级规则应最后执行")

        println("")
    }

    /**
     * 测试 Agenda.clear()
     */
    private func testAgendaClear() {
        println("🧪 测试: Agenda.clear()")

        let agenda = Agenda()
        let facts = ArrayList<Fact>()
        facts.add(OrderFact("ORDER-001", "普通", 1000.0, 3))

        agenda.addActivation(Rule("规则1", 100), facts)
        agenda.addActivation(Rule("规则2", 50), facts)

        // 先触发一条规则,以确认 firedRules 和 fireCount 也被清空
        agenda.fireNext()

        assertEquals(1, agenda.getFiredCount(), "触发一条后计数应为 1")

        agenda.clear()

        assertEquals(0, agenda.getPendingCount(), "清空后待触发数应为 0")
        assertEquals(0, agenda.getFiredCount(), "清空后触发计数应为 0")

        println("")
    }

    /**
     * 测试 Agenda noLoop - 防止已触发规则重复进入议程
     */
    private func testAgendaNoLoop() {
        println("🧪 测试: Agenda noLoop - 防止重复触发")

        let agenda = Agenda()
        let facts = ArrayList<Fact>()
        facts.add(OrderFact("ORDER-001", "普通", 1000.0, 3))

        let rule = Rule("noLoop规则", 100)
        rule.setNoLoop(true)

        // 第一次添加应成功
        agenda.addActivation(rule, facts)
        assertEquals(1, agenda.getPendingCount(), "第一次添加后待触发数应为 1")

        // 触发规则,将其加入 firedRules
        agenda.fireNext()
        assertEquals(0, agenda.getPendingCount(), "触发后待触发数应为 0")

        // noLoop 规则触发后,再次添加应被拒绝
        agenda.addActivation(rule, facts)
        assertEquals(0, agenda.getPendingCount(), "noLoop 规则触发后不应再次加入议程")

        println("")
    }

    /**
     * 测试 Agenda.isRuleFired()
     */
    private func testAgendaIsRuleFired() {
        println("🧪 测试: Agenda.isRuleFired()")

        let agenda = Agenda()
        let facts = ArrayList<Fact>()
        facts.add(OrderFact("ORDER-001", "普通", 1000.0, 3))

        let rule = Rule("测试规则", 100)

        assert(!agenda.isRuleFired("测试规则"), "触发前 isRuleFired 应返回 false")
        assert(!agenda.isRuleFired("不存在规则"), "从未添加的规则 isRuleFired 应返回 false")

        agenda.addActivation(rule, facts)
        assert(!agenda.isRuleFired("测试规则"), "添加但未触发时 isRuleFired 应返回 false")

        agenda.fireNext()
        assert(agenda.isRuleFired("测试规则"), "触发后 isRuleFired 应返回 true")
        assert(!agenda.isRuleFired("其他规则"), "未触发的规则 isRuleFired 应返回 false")

        println("")
    }

    /**
     * 测试 Agenda.getFiredCount()
     */
    private func testAgendaGetFiredCount() {
        println("🧪 测试: Agenda.getFiredCount()")

        let agenda = Agenda()
        let facts = ArrayList<Fact>()
        facts.add(OrderFact("ORDER-001", "普通", 1000.0, 3))

        assertEquals(0, agenda.getFiredCount(), "初始触发计数应为 0")

        agenda.addActivation(Rule("规则1", 100), facts)
        agenda.addActivation(Rule("规则2", 50), facts)

        agenda.fireNext()
        assertEquals(1, agenda.getFiredCount(), "触发 1 条后计数应为 1")

        agenda.fireNext()
        assertEquals(2, agenda.getFiredCount(), "触发 2 条后计数应为 2")

        agenda.fireAll(None)
        assertEquals(2, agenda.getFiredCount(), "所有规则已触发后再调用 fireAll 计数不变")

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
 * 主函数 - 运行 Agenda 和 PatternMatcher 测试
 */
main() {
    let test = AgendaTest()
    let success = test.runAll()

    if (success) {
        println("\n🎉 所有测试通过!")
        System.exit(0)
    } else {
        println("\n⚠️ 存在失败的测试!")
        System.exit(1)
    }
}
