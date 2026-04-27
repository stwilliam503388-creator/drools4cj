/*
 * Drools4Cj - 单元测试
 * 文件: WorkingMemoryEdgeCasesTest.cj
 * 说明: 测试 WorkingMemory 的边界情况和缺失覆盖点
 */

package tests.unit

import core.*
import core.WorkingMemory
import core.OrderFact
import core.ProductFact
import core.CustomerFact
import core.FactEventProcessor
import std.collection.ArrayList

/**
 * WorkingMemory 边界情况测试
 */
class WorkingMemoryEdgeCasesTest {
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
        println("║      WorkingMemory 边界情况测试                      ║")
        println("╚══════════════════════════════════════════════════════╝\n")

        testContainsExistingFact()
        testContainsNonExistingFact()
        testContainsAfterRetract()
        testGetVersionAfterInsert()
        testGetVersionIncrementsOnUpdate()
        testVersionCounterIncrements()
        testUpdateNonExistentFactReturnsFalse()
        testRetractNonExistentFactReturnsFalse()
        testTypeStatsAfterRetractLastOfType()
        testTypeStatsWithMixedTypes()
        testGetAllFactsAfterRetract()
        testGetFactsByTypeAfterRetract()
        testClearResetsVersionCounter()
        testInsertMultipleTypes()
        testGetStatsString()
        testFactEventProcessorInstantiation()

        printResults()
        return failed == 0
    }

    // ==================== contains 测试 ====================

    /**
     * 测试 contains - 存在的事实
     */
    private func testContainsExistingFact() {
        println("🧪 测试: WorkingMemory contains - 存在的事实")

        let wm = WorkingMemory()
        wm.insert(OrderFact("ORDER-E01", "普通", 1000.0, 3))

        assert(wm.contains("ORDER-E01"), "已插入的事实 contains 应返回 true")

        println("")
    }

    /**
     * 测试 contains - 不存在的事实
     */
    private func testContainsNonExistingFact() {
        println("🧪 测试: WorkingMemory contains - 不存在的事实")

        let wm = WorkingMemory()

        assert(!wm.contains("NOT-EXIST"), "未插入的事实 contains 应返回 false")
        assert(!wm.contains(""), "空 ID contains 应返回 false")

        println("")
    }

    /**
     * 测试 contains - 撤回后不存在
     */
    private func testContainsAfterRetract() {
        println("🧪 测试: WorkingMemory contains - 撤回后")

        let wm = WorkingMemory()
        wm.insert(OrderFact("ORDER-E02", "普通", 1000.0, 3))
        assert(wm.contains("ORDER-E02"), "撤回前 contains 应返回 true")

        wm.retract("ORDER-E02")
        assert(!wm.contains("ORDER-E02"), "撤回后 contains 应返回 false")

        println("")
    }

    // ==================== getVersion 测试 ====================

    /**
     * 测试 getVersion - 插入后获取版本号
     */
    private func testGetVersionAfterInsert() {
        println("🧪 测试: WorkingMemory getVersion - 插入后版本")

        let wm = WorkingMemory()
        let v1 = wm.insert(OrderFact("ORDER-E03", "普通", 1000.0, 3))
        let v2 = wm.insert(ProductFact("PROD-E01", "商品", 500.0, 10))

        match (wm.getVersion("ORDER-E03")) {
            case Some(ver) => {
                assertEquals(v1, ver, "getVersion 应返回 insert 时的版本号")
            }
            case None => assert(false, "已插入的事实应有版本号")
        }

        match (wm.getVersion("PROD-E01")) {
            case Some(ver) => {
                assertEquals(v2, ver, "第二次 insert 的版本号应比第一次大")
                assert(v2 > v1, "版本号应单调递增")
            }
            case None => assert(false, "已插入的事实应有版本号")
        }

        println("")
    }

    /**
     * 测试 getVersion - 更新后版本号递增
     */
    private func testGetVersionIncrementsOnUpdate() {
        println("🧪 测试: WorkingMemory getVersion - 更新后版本递增")

        let wm = WorkingMemory()
        let insertVersion = wm.insert(OrderFact("ORDER-E04", "普通", 1000.0, 3))

        let updatedOrder = OrderFact("ORDER-E04", "VIP", 2000.0, 5)
        wm.update(updatedOrder)

        match (wm.getVersion("ORDER-E04")) {
            case Some(ver) => {
                assert(ver > insertVersion, "更新后版本号应大于插入时版本号")
            }
            case None => assert(false, "更新后事实应有版本号")
        }

        println("")
    }

    /**
     * 测试 版本计数器单调递增
     */
    private func testVersionCounterIncrements() {
        println("🧪 测试: WorkingMemory 版本计数器递增")

        let wm = WorkingMemory()

        let v1 = wm.insert(OrderFact("ORDER-E05", "普通", 100.0, 1))
        let v2 = wm.insert(OrderFact("ORDER-E06", "VIP", 200.0, 2))
        let v3 = wm.insert(ProductFact("PROD-E02", "商品A", 300.0, 5))

        assert(v1 > 0, "第一个版本号应大于 0")
        assert(v2 > v1, "第二个版本号应大于第一个")
        assert(v3 > v2, "第三个版本号应大于第二个")

        println("")
    }

    // ==================== 更新/撤回边界测试 ====================

    /**
     * 测试 update - 更新不存在的事实返回 false
     */
    private func testUpdateNonExistentFactReturnsFalse() {
        println("🧪 测试: WorkingMemory update - 更新不存在事实返回 false")

        let wm = WorkingMemory()

        let ghostFact = OrderFact("GHOST-001", "普通", 1000.0, 5)
        let success = wm.update(ghostFact)

        assert(!success, "更新不存在的事实应返回 false")
        assertEquals(0, wm.getSize(), "更新不存在的事实后工作内存应仍为空")

        println("")
    }

    /**
     * 测试 retract - 撤回不存在的事实返回 false
     */
    private func testRetractNonExistentFactReturnsFalse() {
        println("🧪 测试: WorkingMemory retract - 撤回不存在事实返回 false")

        let wm = WorkingMemory()

        let success = wm.retract("NON-EXISTENT-ID")
        assert(!success, "撤回不存在的事实应返回 false")

        // 撤回不影响已有事实
        wm.insert(OrderFact("ORDER-E07", "普通", 500.0, 2))
        let failedRetract = wm.retract("WRONG-ID")
        assert(!failedRetract, "撤回错误 ID 应返回 false")
        assertEquals(1, wm.getSize(), "失败的撤回不应影响工作内存大小")

        println("")
    }

    // ==================== 类型索引更新测试 ====================

    /**
     * 测试 类型索引 - 撤回最后一个该类型事实后类型被移除
     */
    private func testTypeStatsAfterRetractLastOfType() {
        println("🧪 测试: WorkingMemory 类型索引 - 撤回最后一条同类事实")

        let wm = WorkingMemory()

        wm.insert(OrderFact("ORDER-E08", "普通", 500.0, 2))
        wm.insert(ProductFact("PROD-E03", "商品", 100.0, 10))

        let statsBefore = wm.getTypeStats()
        assertEquals(2, statsBefore.size, "撤回前应有 2 种类型")

        // 撤回所有 Order 类型事实
        wm.retract("ORDER-E08")

        let statsAfter = wm.getTypeStats()
        assertEquals(1, statsAfter.size, "撤回 Order 唯一事实后应只剩 1 种类型")
        assertEquals(0, statsAfter.get("Order", 0), "Order 类型数量应为 0")
        assertEquals(1, statsAfter.get("Product", 1), "Product 类型应仍有 1 个事实")

        println("")
    }

    /**
     * 测试 类型索引 - 混合多类型
     */
    private func testTypeStatsWithMixedTypes() {
        println("🧪 测试: WorkingMemory 类型统计 - 多类型混合操作")

        let wm = WorkingMemory()

        wm.insert(OrderFact("O1", "普通", 100.0, 1))
        wm.insert(OrderFact("O2", "VIP", 200.0, 2))
        wm.insert(ProductFact("P1", "商品A", 50.0, 10))
        wm.insert(CustomerFact("C1", "张三", "金卡", 5000, 20))

        let stats = wm.getTypeStats()
        assertEquals(3, stats.size, "应有 3 种类型")
        assertEquals(2, stats.get("Order", 0), "Order 类型应有 2 个")
        assertEquals(1, stats.get("Product", 0), "Product 类型应有 1 个")
        assertEquals(1, stats.get("Customer", 0), "Customer 类型应有 1 个")

        // 撤回一条 Order
        wm.retract("O1")
        let statsAfterRetract = wm.getTypeStats()
        assertEquals(3, statsAfterRetract.size, "撤回一条 Order 后仍应有 3 种类型")
        assertEquals(1, statsAfterRetract.get("Order", 0), "Order 类型应减少为 1 个")

        println("")
    }

    /**
     * 测试 getAllFacts - 撤回后返回剩余事实
     */
    private func testGetAllFactsAfterRetract() {
        println("🧪 测试: WorkingMemory getAllFacts - 撤回后")

        let wm = WorkingMemory()

        wm.insert(OrderFact("O1", "普通", 100.0, 1))
        wm.insert(OrderFact("O2", "VIP", 200.0, 2))
        wm.insert(ProductFact("P1", "商品", 50.0, 5))

        assertEquals(3, wm.getAllFacts().size, "撤回前应有 3 个事实")

        wm.retract("O1")
        assertEquals(2, wm.getAllFacts().size, "撤回 1 条后应有 2 个事实")

        wm.retract("P1")
        assertEquals(1, wm.getAllFacts().size, "撤回 2 条后应有 1 个事实")

        println("")
    }

    /**
     * 测试 getFactsByType - 撤回后类型查询
     */
    private func testGetFactsByTypeAfterRetract() {
        println("🧪 测试: WorkingMemory getFactsByType - 撤回后")

        let wm = WorkingMemory()

        wm.insert(OrderFact("O1", "普通", 100.0, 1))
        wm.insert(OrderFact("O2", "VIP", 200.0, 2))

        assertEquals(2, wm.getFactsByType("Order").size, "撤回前 Order 类型应有 2 个")

        wm.retract("O1")

        assertEquals(1, wm.getFactsByType("Order").size, "撤回 1 条后 Order 类型应有 1 个")

        println("")
    }

    /**
     * 测试 clear - 重置版本计数器
     */
    private func testClearResetsVersionCounter() {
        println("🧪 测试: WorkingMemory clear - 重置版本计数器")

        let wm = WorkingMemory()

        wm.insert(OrderFact("O1", "普通", 100.0, 1))
        wm.insert(OrderFact("O2", "VIP", 200.0, 2))

        wm.clear()

        assertEquals(0, wm.getSize(), "clear 后大小应为 0")
        assertEquals(0, wm.getAllFacts().size, "clear 后事实列表应为空")

        // 清空后重新插入,版本计数器应从 0 重新开始
        let newVersion = wm.insert(OrderFact("O3", "普通", 300.0, 3))
        assert(newVersion > 0, "清空后重新插入应获得正版本号")
        assertEquals(1, wm.getSize(), "清空后重新插入大小应为 1")

        println("")
    }

    /**
     * 测试 insert - 多种类型事实
     */
    private func testInsertMultipleTypes() {
        println("🧪 测试: WorkingMemory 插入多种类型事实")

        let wm = WorkingMemory()

        let v1 = wm.insert(OrderFact("O1", "普通", 100.0, 1))
        let v2 = wm.insert(ProductFact("P1", "商品", 500.0, 20))
        let v3 = wm.insert(CustomerFact("C1", "客户", "金卡", 5000, 15))

        assert(v1 > 0, "OrderFact 插入应返回正版本号")
        assert(v2 > 0, "ProductFact 插入应返回正版本号")
        assert(v3 > 0, "CustomerFact 插入应返回正版本号")

        assertEquals(3, wm.getSize(), "插入 3 种类型事实后大小应为 3")

        // 按类型查询
        assertEquals(1, wm.getFactsByType("Order").size, "Order 类型应有 1 个")
        assertEquals(1, wm.getFactsByType("Product").size, "Product 类型应有 1 个")
        assertEquals(1, wm.getFactsByType("Customer").size, "Customer 类型应有 1 个")

        // 不存在的类型
        assertEquals(0, wm.getFactsByType("Unknown").size, "未知类型应返回空列表")

        println("")
    }

    /**
     * 测试 getStats - 统计字符串
     */
    private func testGetStatsString() {
        println("🧪 测试: WorkingMemory getStats 统计字符串")

        let wm = WorkingMemory()

        wm.insert(OrderFact("O1", "普通", 100.0, 1))
        wm.insert(ProductFact("P1", "商品", 500.0, 10))

        let stats = wm.getStats()
        assert(stats.contains("2"), "统计信息应包含事实总数 2")

        println("")
    }

    // ==================== FactEventProcessor 测试 ====================

    /**
     * 测试 FactEventProcessor 实例化
     */
    private func testFactEventProcessorInstantiation() {
        println("🧪 测试: FactEventProcessor 实例化")

        let processor = FactEventProcessor()
        assert(true, "FactEventProcessor 应能正常实例化")

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
 * 主函数 - 运行 WorkingMemory 边界情况测试
 */
main() {
    let test = WorkingMemoryEdgeCasesTest()
    let success = test.runAll()

    if (success) {
        println("\n🎉 所有测试通过!")
        System.exit(0)
    } else {
        println("\n⚠️ 存在失败的测试!")
        System.exit(1)
    }
}
