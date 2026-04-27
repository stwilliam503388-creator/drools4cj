/*
 * Drools4Cj - 单元测试
 * 文件: MatcherAndAgendaTest.cj
 * 说明: 测试 PatternMatcher 和 Agenda 类
 */

package tests.unit

import core.*
import core.PatternMatcher
import core.Agenda
import core.Match
import core.Activation
import core.WorkingMemory
import core.Rule
import core.RuleBuilder
import core.OrderFact
import core.ProductFact
import core.PropertyValue
import std.collection.ArrayList

/**
 * PatternMatcher 和 Agenda 单元测试
 */
class MatcherAndAgendaTest {
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

        testPatternMatcherMatchRulesEmpty()
        testPatternMatcherMatchRulesMatching()
        testPatternMatcherMatchRulesNonMatching()
        testPatternMatcherMatchRulesDisabledRule()
        testPatternMatcherMatchRule()
        testPatternMatcherIncrementalMatch()
        testPatternMatcherMatchCount()
        testPatternMatcherReset()
        testPatternMatcherMultipleRules()
        testAgendaAddActivation()
        testAgendaFireNext()
        testAgendaFireNextReturnsZeroWhenEmpty()
        testAgendaFireAll()
        testAgendaFireAllReturnsCount()
        testAgendaPendingCount()
        testAgendaFiredCount()
        testAgendaIsRuleFired()
        testAgendaClear()
        testAgendaNoLoopPreventsRetrigger()
        testAgendaSortByPriority()

        printResults()
        return failed == 0
    }

    // ==================== PatternMatcher 测试 ====================

    /**
     * 测试 matchRules - 无规则时返回空列表
     */
    private func testPatternMatcherMatchRulesEmpty() {
        println("🧪 测试: PatternMatcher matchRules - 空规则列表")

        let wm = WorkingMemory()
        let matcher = PatternMatcher(wm)
        let rules = ArrayList<Rule>()

        wm.insert(OrderFact("O001", "普通", 1000.0, 5))

        let matches = matcher.matchRules(rules)
        assertEquals(0, matches.size, "空规则列表应返回空匹配列表")

        println("")
    }

    /**
     * 测试 matchRules - 规则匹配事实
     */
    private func testPatternMatcherMatchRulesMatching() {
        println("🧪 测试: PatternMatcher matchRules - 规则与事实匹配")

        let wm = WorkingMemory()
        let matcher = PatternMatcher(wm)
        let rules = ArrayList<Rule>()

        let rule = Rule("金额规则")
        rule.addCondition("amount", ">", PropertyValue(500.0))
        rules.add(rule)

        wm.insert(OrderFact("O001", "普通", 1000.0, 5))

        let matches = matcher.matchRules(rules)
        assert(matches.size > 0, "满足条件的规则应有匹配结果")
        assertEquals("金额规则", matches[0].rule.name, "匹配结果的规则名称应正确")

        println("")
    }

    /**
     * 测试 matchRules - 规则不匹配事实
     */
    private func testPatternMatcherMatchRulesNonMatching() {
        println("🧪 测试: PatternMatcher matchRules - 规则不匹配事实")

        let wm = WorkingMemory()
        let matcher = PatternMatcher(wm)
        let rules = ArrayList<Rule>()

        let rule = Rule("高金额规则")
        rule.addCondition("amount", ">", PropertyValue(5000.0))
        rules.add(rule)

        wm.insert(OrderFact("O001", "普通", 500.0, 3))

        let matches = matcher.matchRules(rules)
        assertEquals(0, matches.size, "不满足条件的规则不应有匹配结果")

        println("")
    }

    /**
     * 测试 matchRules - 禁用规则被跳过
     */
    private func testPatternMatcherMatchRulesDisabledRule() {
        println("🧪 测试: PatternMatcher matchRules - 禁用规则被跳过")

        let wm = WorkingMemory()
        let matcher = PatternMatcher(wm)
        let rules = ArrayList<Rule>()

        let rule = Rule("禁用规则")
        rule.addCondition("amount", ">", PropertyValue(100.0))
        rule.setEnabled(false)
        rules.add(rule)

        wm.insert(OrderFact("O001", "普通", 1000.0, 5))

        let matches = matcher.matchRules(rules)
        assertEquals(0, matches.size, "禁用规则不应产生匹配结果")

        println("")
    }

    /**
     * 测试 matchRule - 单规则匹配多个事实
     */
    private func testPatternMatcherMatchRule() {
        println("🧪 测试: PatternMatcher matchRule - 匹配多个事实")

        let wm = WorkingMemory()
        let matcher = PatternMatcher(wm)

        let rule = Rule("金额规则")
        rule.addCondition("amount", ">", PropertyValue(1000.0))

        wm.insert(OrderFact("O001", "普通", 1500.0, 3))
        wm.insert(OrderFact("O002", "VIP", 2000.0, 5))
        wm.insert(OrderFact("O003", "普通", 500.0, 2))

        let results = matcher.matchRule(rule)
        assertEquals(2, results.size, "2 个满足条件的事实应各产生 1 条匹配")

        println("")
    }

    /**
     * 测试 incrementalMatch - 新增事实触发增量匹配
     */
    private func testPatternMatcherIncrementalMatch() {
        println("🧪 测试: PatternMatcher incrementalMatch - 新增事实匹配")

        let wm = WorkingMemory()
        let matcher = PatternMatcher(wm)
        let rules = ArrayList<Rule>()

        let rule1 = Rule("金额规则")
        rule1.addCondition("amount", ">", PropertyValue(500.0))
        rules.add(rule1)

        let rule2 = Rule("VIP规则")
        rule2.addCondition("customer", "=", PropertyValue("VIP"))
        rules.add(rule2)

        // 新事实匹配两个规则
        let newFact = OrderFact("O001", "VIP", 1000.0, 5)
        let matches = matcher.incrementalMatch(rules, newFact)
        assertEquals(2, matches.size, "同时匹配两个规则的事实应产生 2 条增量匹配")

        // 新事实只匹配一个规则
        let partialFact = OrderFact("O002", "普通", 1000.0, 5)
        let partialMatches = matcher.incrementalMatch(rules, partialFact)
        assertEquals(1, partialMatches.size, "只匹配一个规则的事实应产生 1 条增量匹配")

        // 新事实不匹配任何规则
        let noMatchFact = OrderFact("O003", "普通", 100.0, 1)
        let noMatches = matcher.incrementalMatch(rules, noMatchFact)
        assertEquals(0, noMatches.size, "不匹配任何规则的事实应产生 0 条增量匹配")

        println("")
    }

    /**
     * 测试 getMatchCount - 匹配次数统计
     */
    private func testPatternMatcherMatchCount() {
        println("🧪 测试: PatternMatcher getMatchCount 计数")

        let wm = WorkingMemory()
        let matcher = PatternMatcher(wm)
        let rules = ArrayList<Rule>()

        let rule = Rule("计数规则")
        rule.addCondition("amount", ">", PropertyValue(100.0))
        rules.add(rule)

        assertEquals(0, matcher.getMatchCount(), "初始匹配次数应为 0")

        wm.insert(OrderFact("O001", "普通", 500.0, 3))
        matcher.matchRules(rules)

        assert(matcher.getMatchCount() > 0, "匹配后计数应大于 0")

        println("")
    }

    /**
     * 测试 reset - 重置匹配计数
     */
    private func testPatternMatcherReset() {
        println("🧪 测试: PatternMatcher reset 重置计数")

        let wm = WorkingMemory()
        let matcher = PatternMatcher(wm)
        let rules = ArrayList<Rule>()

        let rule = Rule("重置测试规则")
        rule.addCondition("amount", ">", PropertyValue(100.0))
        rules.add(rule)

        wm.insert(OrderFact("O001", "普通", 500.0, 3))
        matcher.matchRules(rules)
        assert(matcher.getMatchCount() > 0, "匹配后计数应大于 0")

        matcher.reset()
        assertEquals(0, matcher.getMatchCount(), "reset 后计数应恢复为 0")

        println("")
    }

    /**
     * 测试 matchRules - 多规则匹配
     */
    private func testPatternMatcherMultipleRules() {
        println("🧪 测试: PatternMatcher matchRules - 多规则场景")

        let wm = WorkingMemory()
        let matcher = PatternMatcher(wm)
        let rules = ArrayList<Rule>()

        let rule1 = Rule("金额规则")
        rule1.addCondition("amount", ">", PropertyValue(1000.0))
        rules.add(rule1)

        let rule2 = Rule("商品数规则")
        rule2.addCondition("items", ">", PropertyValue(5))
        rules.add(rule2)

        // 同时满足两个规则的事实
        wm.insert(OrderFact("O001", "普通", 1500.0, 10))
        // 只满足金额规则
        wm.insert(OrderFact("O002", "普通", 1200.0, 2))

        let matches = matcher.matchRules(rules)

        // O001 满足 rule1 和 rule2 (2 次), O002 满足 rule1 (1 次) → 共 3 次
        assertEquals(3, matches.size, "应有 3 条匹配 (O001×2 + O002×1)")

        println("")
    }

    // ==================== Agenda 测试 ====================

    /**
     * 测试 addActivation - 正常添加激活
     */
    private func testAgendaAddActivation() {
        println("🧪 测试: Agenda addActivation 添加激活")

        let agenda = Agenda()
        let rule = RuleBuilder("激活测试规则")
            .when("amount", ">", PropertyValue(100.0))
            .then({ })
            .build()

        var facts = ArrayList<Fact>()
        facts.add(OrderFact("O001", "普通", 500.0, 3))

        assertEquals(0, agenda.getPendingCount(), "初始待触发数应为 0")

        agenda.addActivation(rule, facts)
        assertEquals(1, agenda.getPendingCount(), "添加激活后待触发数应为 1")

        // 再添加一个激活
        agenda.addActivation(rule, facts)
        assertEquals(2, agenda.getPendingCount(), "再添加后待触发数应为 2")

        println("")
    }

    /**
     * 测试 fireNext - 触发下一条规则
     */
    private func testAgendaFireNext() {
        println("🧪 测试: Agenda fireNext 触发单条规则")

        let agenda = Agenda()
        var executed = false

        let rule = RuleBuilder("单条触发规则")
            .when("amount", ">", PropertyValue(100.0))
            .then({ executed = true })
            .build()

        var facts = ArrayList<Fact>()
        facts.add(OrderFact("O001", "普通", 500.0, 3))

        agenda.addActivation(rule, facts)
        assertEquals(1, agenda.getPendingCount(), "触发前待触发数应为 1")

        let fired = agenda.fireNext()
        assertEquals(1, fired, "fireNext 应返回 1 (触发了 1 条规则)")
        assert(executed, "规则动作应被执行")
        assertEquals(0, agenda.getPendingCount(), "触发后待触发数应为 0")

        println("")
    }

    /**
     * 测试 fireNext - 无待触发规则时返回 0
     */
    private func testAgendaFireNextReturnsZeroWhenEmpty() {
        println("🧪 测试: Agenda fireNext - 空议程返回 0")

        let agenda = Agenda()
        let fired = agenda.fireNext()
        assertEquals(0, fired, "空议程 fireNext 应返回 0")

        println("")
    }

    /**
     * 测试 fireAll - 触发所有规则
     */
    private func testAgendaFireAll() {
        println("🧪 测试: Agenda fireAll 触发所有规则")

        let agenda = Agenda()
        var count = 0

        let rule1 = RuleBuilder("全触发规则1")
            .when("amount", ">", PropertyValue(100.0))
            .then({ count++ })
            .build()

        let rule2 = RuleBuilder("全触发规则2")
            .when("items", ">", PropertyValue(1))
            .then({ count++ })
            .build()

        var facts = ArrayList<Fact>()
        facts.add(OrderFact("O001", "普通", 500.0, 3))

        agenda.addActivation(rule1, facts)
        agenda.addActivation(rule2, facts)

        agenda.fireAll(None)

        assertEquals(2, count, "两条规则的动作都应被执行")
        assertEquals(0, agenda.getPendingCount(), "fireAll 后待触发数应为 0")

        println("")
    }

    /**
     * 测试 fireAll - 返回已触发数量
     */
    private func testAgendaFireAllReturnsCount() {
        println("🧪 测试: Agenda fireAll 返回触发数量")

        let agenda = Agenda()

        let rule1 = RuleBuilder("计数规则1")
            .then({ })
            .build()

        let rule2 = RuleBuilder("计数规则2")
            .then({ })
            .build()

        let rule3 = RuleBuilder("计数规则3")
            .then({ })
            .build()

        var facts = ArrayList<Fact>()
        facts.add(OrderFact("O001", "普通", 500.0, 3))

        agenda.addActivation(rule1, facts)
        agenda.addActivation(rule2, facts)
        agenda.addActivation(rule3, facts)

        let firedCount = agenda.fireAll(None)
        assertEquals(3, firedCount, "fireAll 应返回实际触发的规则数 3")

        println("")
    }

    /**
     * 测试 getPendingCount - 待触发数量
     */
    private func testAgendaPendingCount() {
        println("🧪 测试: Agenda getPendingCount 待触发计数")

        let agenda = Agenda()

        let rule = RuleBuilder("待触发规则")
            .then({ })
            .build()

        var facts = ArrayList<Fact>()
        facts.add(OrderFact("O001", "普通", 100.0, 1))

        assertEquals(0, agenda.getPendingCount(), "初始待触发数应为 0")

        agenda.addActivation(rule, facts)
        assertEquals(1, agenda.getPendingCount(), "添加 1 条激活后待触发数应为 1")

        agenda.addActivation(rule, facts)
        assertEquals(2, agenda.getPendingCount(), "添加 2 条激活后待触发数应为 2")

        agenda.fireNext()
        assertEquals(1, agenda.getPendingCount(), "触发 1 条后待触发数应为 1")

        agenda.fireNext()
        assertEquals(0, agenda.getPendingCount(), "全部触发后待触发数应为 0")

        println("")
    }

    /**
     * 测试 getFiredCount - 已触发数量
     */
    private func testAgendaFiredCount() {
        println("🧪 测试: Agenda getFiredCount 已触发计数")

        let agenda = Agenda()

        let rule = RuleBuilder("已触发计数规则")
            .then({ })
            .build()

        var facts = ArrayList<Fact>()
        facts.add(OrderFact("O001", "普通", 100.0, 1))

        assertEquals(0, agenda.getFiredCount(), "初始已触发数应为 0")

        agenda.addActivation(rule, facts)
        agenda.fireNext()
        assertEquals(1, agenda.getFiredCount(), "触发 1 条后已触发数应为 1")

        agenda.addActivation(rule, facts)
        agenda.fireNext()
        assertEquals(2, agenda.getFiredCount(), "再触发 1 条后已触发数应为 2")

        println("")
    }

    /**
     * 测试 isRuleFired - 规则是否已触发
     */
    private func testAgendaIsRuleFired() {
        println("🧪 测试: Agenda isRuleFired 规则触发状态")

        let agenda = Agenda()

        let rule = RuleBuilder("触发状态规则")
            .then({ })
            .build()

        var facts = ArrayList<Fact>()
        facts.add(OrderFact("O001", "普通", 100.0, 1))

        assert(!agenda.isRuleFired("触发状态规则"), "触发前规则状态应为未触发")

        agenda.addActivation(rule, facts)
        agenda.fireNext()

        assert(agenda.isRuleFired("触发状态规则"), "触发后规则状态应为已触发")
        assert(!agenda.isRuleFired("不存在的规则"), "未添加的规则状态应为未触发")

        println("")
    }

    /**
     * 测试 clear - 清空议程
     */
    private func testAgendaClear() {
        println("🧪 测试: Agenda clear 清空议程")

        let agenda = Agenda()

        let rule = RuleBuilder("清空测试规则")
            .then({ })
            .build()

        var facts = ArrayList<Fact>()
        facts.add(OrderFact("O001", "普通", 100.0, 1))

        agenda.addActivation(rule, facts)
        agenda.addActivation(rule, facts)
        agenda.addActivation(rule, facts)
        assert(agenda.getPendingCount() > 0, "清空前应有待触发激活")

        // 触发一条,然后清空
        agenda.fireNext()
        agenda.clear()

        assertEquals(0, agenda.getPendingCount(), "清空后待触发数应为 0")
        assertEquals(0, agenda.getFiredCount(), "clear 后已触发数应为 0")
        assert(!agenda.isRuleFired("清空测试规则"), "clear 后规则触发状态应被重置")

        println("")
    }

    /**
     * 测试 noLoop - 防止规则循环触发
     */
    private func testAgendaNoLoopPreventsRetrigger() {
        println("🧪 测试: Agenda noLoop 防止循环触发")

        let agenda = Agenda()

        let noLoopRule = RuleBuilder("NoLoop规则")
            .noLoop(true)
            .then({ })
            .build()

        var facts = ArrayList<Fact>()
        facts.add(OrderFact("O001", "普通", 100.0, 1))

        // 第一次添加激活 - 应成功
        agenda.addActivation(noLoopRule, facts)
        assertEquals(1, agenda.getPendingCount(), "noLoop 规则首次添加应成功")

        // 触发该规则
        agenda.fireNext()
        assertEquals(0, agenda.getPendingCount(), "触发后待触发数应为 0")
        assert(agenda.isRuleFired("NoLoop规则"), "规则应被标记为已触发")

        // 再次添加激活 - 应被 noLoop 阻止
        agenda.addActivation(noLoopRule, facts)
        assertEquals(0, agenda.getPendingCount(), "noLoop 规则第二次添加应被阻止")

        println("")
    }

    /**
     * 测试 sortActivations - 按优先级排序
     */
    private func testAgendaSortByPriority() {
        println("🧪 测试: Agenda 按优先级排序触发")

        let agenda = Agenda()
        var executionOrder = ArrayList<String>()

        let lowRule = RuleBuilder("低优先级")
            .salience(10)
            .then({ executionOrder.add("低优先级") })
            .build()

        let highRule = RuleBuilder("高优先级")
            .salience(100)
            .then({ executionOrder.add("高优先级") })
            .build()

        let midRule = RuleBuilder("中优先级")
            .salience(50)
            .then({ executionOrder.add("中优先级") })
            .build()

        var facts = ArrayList<Fact>()
        facts.add(OrderFact("O001", "普通", 100.0, 1))

        // 按低、高、中顺序添加激活
        agenda.addActivation(lowRule, facts)
        agenda.addActivation(highRule, facts)
        agenda.addActivation(midRule, facts)

        // 触发所有规则
        agenda.fireAll(None)

        assertEquals(3, executionOrder.size, "应触发 3 条规则")
        assertEquals("高优先级", executionOrder[0], "高优先级规则应最先执行")
        assertEquals("中优先级", executionOrder[1], "中优先级规则应第二执行")
        assertEquals("低优先级", executionOrder[2], "低优先级规则应最后执行")

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
 * 主函数 - 运行 PatternMatcher 和 Agenda 测试
 */
main() {
    let test = MatcherAndAgendaTest()
    let success = test.runAll()

    if (success) {
        println("\n🎉 所有测试通过!")
        System.exit(0)
    } else {
        println("\n⚠️ 存在失败的测试!")
        System.exit(1)
    }
}
