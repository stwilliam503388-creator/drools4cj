/*
 * Drools4Cj - 单元测试
 * 文件: WorkingMemoryTest.cj
 * 说明: 测试 WorkingMemory 类
 */

package tests.unit

import core.*
import core.WorkingMemory
import core.OrderFact
import core.ProductFact
import core.CustomerFact

/**
 * WorkingMemory 类单元测试
 */
class WorkingMemoryTest {
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
        println("║      WorkingMemory 类单元测试                        ║")
        println("╚══════════════════════════════════════════════════════╝\n")

        testInsertFact()
        testUpdateFact()
        testRetractFact()
        testGetFact()
        testGetFactsByType()
        testGetAllFacts()
        testGetSize()
        testTypeIndex()
        testClear()
        testContains()
        testGetVersion()
        testUpdateNonExistent()
        testRetractNonExistent()
        testTypeIndexCleanupOnRetract()

        printResults()
        return failed == 0
    }

    /**
     * 测试插入事实
     */
    private func testInsertFact() {
        println("🧪 测试: 插入事实")

        let wm = WorkingMemory()
        let order = OrderFact("ORDER-001", "普通", 1000.0, 3)

        let version = wm.insert(order)

        assert(version > 0, "插入应返回正版本号")
        assertEquals(1, wm.getSize(), "工作内存大小应为 1")

        // 验证事实可以获取
        match (wm.getFact("ORDER-001")) {
            case Some(fact) => assert(fact.id == "ORDER-001", "获取的事实ID应正确")
            case None => assert(false, "应能获取到插入的事实")
        }

        println("")
    }

    /**
     * 测试更新事实
     */
    private func testUpdateFact() {
        println("🧪 测试: 更新事实")

        let wm = WorkingMemory()
        let order = OrderFact("ORDER-002", "普通", 1000.0, 3)

        wm.insert(order)

        // 更新金额
        let updatedOrder = OrderFact("ORDER-002", "VIP", 2000.0, 5)
        let success = wm.update(updatedOrder)

        assert(success, "更新应成功")

        match (wm.getFact("ORDER-002")) {
            case Some(fact) => {
                match (fact) {
                    case OrderFact => {
                        let of = fact as OrderFact
                        assertEquals(2000.0, of.amount, "金额应更新为 2000.0")
                        assertEquals("VIP", of.customer, "客户类型应更新为 VIP")
                    }
                    case _ => assert(false, "应为 OrderFact 类型")
                }
            }
            case None => assert(false, "应能获取到更新的事实")
        }

        println("")
    }

    /**
     * 测试撤回事实
     */
    private func testRetractFact() {
        println("🧪 测试: 撤回事实")

        let wm = WorkingMemory()
        let order = OrderFact("ORDER-003", "普通", 1000.0, 3)

        wm.insert(order)
        assertEquals(1, wm.getSize(), "插入后大小应为 1")

        let success = wm.retract("ORDER-003")
        assert(success, "撤回应成功")
        assertEquals(0, wm.getSize(), "撤回后大小应为 0")

        // 验证事实不存在
        match (wm.getFact("ORDER-003")) {
            case Some(_) => assert(false, "事实不应存在")
            case None => assert(true, "事实应已被撤回")
        }

        println("")
    }

    /**
     * 测试获取事实
     */
    private func testGetFact() {
        println("🧪 测试: 获取事实")

        let wm = WorkingMemory()
        let order = OrderFact("ORDER-004", "VIP", 1500.0, 8)

        wm.insert(order)

        // 测试获取存在的事实
        match (wm.getFact("ORDER-004")) {
            case Some(fact) => {
                assertEquals("ORDER-004", fact.id, "获取的事实ID应正确")
            }
            case None => assert(false, "应能获取到事实")
        }

        // 测试获取不存在的事实
        match (wm.getFact("NOT-EXIST")) {
            case Some(_) => assert(false, "不应获取到不存在的事实")
            case None => assert(true, "应返回 None")
        }

        println("")
    }

    /**
     * 测试按类型获取事实
     */
    private func testGetFactsByType() {
        println("🧪 测试: 按类型获取事实")

        let wm = WorkingMemory()

        wm.insert(OrderFact("ORDER-005", "普通", 1000.0, 3))
        wm.insert(OrderFact("ORDER-006", "VIP", 2000.0, 5))
        wm.insert(ProductFact("PROD-001", "iPhone", 7999.0, 50))

        // 获取所有 Order 类型事实
        let orders = wm.getFactsByType("Order")
        assertEquals(2, orders.size, "应有 2 个 Order 类型事实")

        // 获取所有 Product 类型事实
        let products = wm.getFactsByType("Product")
        assertEquals(1, products.size, "应有 1 个 Product 类型事实")

        // 获取不存在类型
        let customers = wm.getFactsByType("Customer")
        assertEquals(0, customers.size, "不应有 Customer 类型事实")

        println("")
    }

    /**
     * 测试获取所有事实
     */
    private func testGetAllFacts() {
        println("🧪 测试: 获取所有事实")

        let wm = WorkingMemory()

        wm.insert(OrderFact("ORDER-007", "普通", 1000.0, 3))
        wm.insert(ProductFact("PROD-002", "iPad", 3999.0, 30))
        wm.insert(CustomerFact("CUST-001", "张三", "金卡", 5000, 20))

        let allFacts = wm.getAllFacts()
        assertEquals(3, allFacts.size, "应有 3 个事实")

        println("")
    }

    /**
     * 测试获取大小
     */
    private func testGetSize() {
        println("🧪 测试: 获取大小")

        let wm = WorkingMemory()

        assertEquals(0, wm.getSize(), "初始大小应为 0")

        wm.insert(OrderFact("ORDER-008", "普通", 1000.0, 3))
        assertEquals(1, wm.getSize(), "插入1个后大小应为 1")

        wm.insert(OrderFact("ORDER-009", "VIP", 2000.0, 5))
        assertEquals(2, wm.getSize(), "插入2个后大小应为 2")

        wm.retract("ORDER-008")
        assertEquals(1, wm.getSize(), "撤回1个后大小应为 1")

        println("")
    }

    /**
     * 测试类型索引
     */
    private func testTypeIndex() {
        println("🧪 测试: 类型索引")

        let wm = WorkingMemory()

        wm.insert(OrderFact("ORDER-010", "普通", 1000.0, 3))
        wm.insert(OrderFact("ORDER-011", "VIP", 2000.0, 5))
        wm.insert(ProductFact("PROD-003", "MacBook", 15999.0, 10))
        wm.insert(CustomerFact("CUST-002", "李四", "钻石", 10000, 50))

        let stats = wm.getTypeStats()

        assertEquals(3, stats.size, "应有 3 种类型")
        assertEquals(2, stats.get("Order", 0), "Order 类型应有 2 个事实")
        assertEquals(1, stats.get("Product", 0), "Product 类型应有 1 个事实")
        assertEquals(1, stats.get("Customer", 0), "Customer 类型应有 1 个事实")

        println("")
    }

    /**
     * 测试清空工作内存
     */
    private func testClear() {
        println("🧪 测试: 清空工作内存")

        let wm = WorkingMemory()

        wm.insert(OrderFact("ORDER-012", "普通", 1000.0, 3))
        wm.insert(ProductFact("PROD-004", "AirPods", 1299.0, 100))
        wm.insert(CustomerFact("CUST-003", "王五", "银卡", 2000, 10))

        assert(wm.getSize() > 0, "清空前应有事实")

        wm.clear()

        assertEquals(0, wm.getSize(), "清空后大小应为 0")

        let allFacts = wm.getAllFacts()
        assertEquals(0, allFacts.size, "清空后不应有事实")

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
     * 测试 contains() 方法
     */
    private func testContains() {
        println("🧪 测试: contains()")

        let wm = WorkingMemory()

        assert(!wm.contains("ORDER-001"), "插入前事实不应存在")

        wm.insert(OrderFact("ORDER-001", "普通", 1000.0, 3))
        assert(wm.contains("ORDER-001"), "插入后事实应存在")
        assert(!wm.contains("ORDER-002"), "未插入的事实不应存在")

        wm.retract("ORDER-001")
        assert(!wm.contains("ORDER-001"), "撤回后事实不应存在")

        println("")
    }

    /**
     * 测试 getVersion() 方法
     */
    private func testGetVersion() {
        println("🧪 测试: getVersion()")

        let wm = WorkingMemory()
        let order = OrderFact("ORDER-001", "普通", 1000.0, 3)

        let insertVersion = wm.insert(order)

        // 插入后版本应与返回的版本一致
        match (wm.getVersion("ORDER-001")) {
            case Some(v) => assertEquals(insertVersion, v, "getVersion 应返回插入时的版本号")
            case None => assert(false, "插入后应能获取版本号")
        }

        // 更新后版本号应增加
        let updatedOrder = OrderFact("ORDER-001", "VIP", 2000.0, 5)
        wm.update(updatedOrder)

        match (wm.getVersion("ORDER-001")) {
            case Some(v) => assert(v > insertVersion, "更新后版本号应增加")
            case None => assert(false, "更新后应能获取版本号")
        }

        println("")
    }

    /**
     * 测试 update() 非存在事实应返回 false
     */
    private func testUpdateNonExistent() {
        println("🧪 测试: update() 非存在事实应返回 false")

        let wm = WorkingMemory()
        let nonExistentOrder = OrderFact("NON-EXISTENT", "普通", 1000.0, 3)

        let success = wm.update(nonExistentOrder)
        assert(!success, "更新不存在的事实应返回 false")
        assertEquals(0, wm.getSize(), "工作内存大小不应改变")

        println("")
    }

    /**
     * 测试 retract() 非存在事实应返回 false
     */
    private func testRetractNonExistent() {
        println("🧪 测试: retract() 非存在事实应返回 false")

        let wm = WorkingMemory()

        let success = wm.retract("NON-EXISTENT")
        assert(!success, "撤回不存在的事实应返回 false")

        // 插入一个事实后,撤回不存在的不影响现有事实
        wm.insert(OrderFact("ORDER-001", "普通", 1000.0, 3))
        let successAfterInsert = wm.retract("NON-EXISTENT")
        assert(!successAfterInsert, "撤回不存在的事实仍应返回 false")
        assertEquals(1, wm.getSize(), "现有事实不应受影响")

        println("")
    }

    /**
     * 测试撤回最后一个事实时类型索引被清理
     */
    private func testTypeIndexCleanupOnRetract() {
        println("🧪 测试: 撤回最后一个同类型事实时类型索引被清理")

        let wm = WorkingMemory()

        wm.insert(OrderFact("ORDER-001", "普通", 1000.0, 3))
        wm.insert(ProductFact("PROD-001", "iPhone", 7999.0, 50))

        let statsBefore = wm.getTypeStats()
        assertEquals(2, statsBefore.size, "插入后应有 2 种类型")

        // 撤回所有 Order 类型事实
        wm.retract("ORDER-001")

        let statsAfter = wm.getTypeStats()
        assertEquals(1, statsAfter.size, "撤回所有 Order 后应只剩 1 种类型")

        // Order 类型应从索引中移除
        let orderFacts = wm.getFactsByType("Order")
        assertEquals(0, orderFacts.size, "Order 类型不应再有事实")

        // Product 类型不受影响
        let productFacts = wm.getFactsByType("Product")
        assertEquals(1, productFacts.size, "Product 类型应仍有 1 个事实")

        println("")
    }
}

main() {
    let test = WorkingMemoryTest()
    let success = test.runAll()

    if (success) {
        println("\n🎉 所有测试通过!")
        System.exit(0)
    } else {
        println("\n⚠️ 存在失败的测试!")
        System.exit(1)
    }
}
