/*
 * Drools4Cj - 单元测试
 * 文件: FactTest.cj
 * 说明: 测试 Fact 类及其子类
 */

package tests.unit

import core.*
import core.Fact
import core.OrderFact
import core.ProductFact
import core.CustomerFact
import core.Condition
import core.PropertyValue

/**
 * Fact 类单元测试
 */
class FactTest {
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
        println("║         Fact 类单元测试                              ║")
        println("╚══════════════════════════════════════════════════════╝\n")

        testOrderFactCreation()
        testOrderFactAmountConditions()
        testOrderFactItemsConditions()
        testOrderFactCustomerConditions()
        testProductFactCreation()
        testProductFactPriceConditions()
        testProductFactStockConditions()
        testCustomerFactCreation()
        testCustomerFactLevelConditions()
        testCustomerFactPointsConditions()

        printResults()
        return failed == 0
    }

    /**
     * 测试 OrderFact 创建
     */
    private func testOrderFactCreation() {
        println("🧪 测试: OrderFact 创建")

        let order = OrderFact("ORDER-001", "VIP", 1200.0, 5)

        assertEquals("Order", order.type, "类型应为 Order")
        assertEquals("ORDER-001", order.id, "ID 应正确")
        assertEquals("VIP", order.customer, "客户类型应为 VIP")
        assertEquals(1200.0, order.amount, "金额应为 1200.0")
        assertEquals(5, order.items, "商品数应为 5")

        println("")
    }

    /**
     * 测试 OrderFact 金额条件
     */
    private func testOrderFactAmountConditions() {
        println("🧪 测试: OrderFact 金额条件匹配")

        let order = OrderFact("ORDER-001", "普通", 1200.0, 5)

        // 测试大于
        let cond1 = Condition("amount", ">", PropertyValue(1000.0))
        assert(order.matches(cond1), "金额 1200.0 > 1000.0 应匹配")

        // 测试小于
        let cond2 = Condition("amount", "<", PropertyValue(1500.0))
        assert(order.matches(cond2), "金额 1200.0 < 1500.0 应匹配")

        // 测试等于
        let cond3 = Condition("amount", "=", PropertyValue(1200.0))
        assert(order.matches(cond3), "金额 1200.0 = 1200.0 应匹配")

        // 测试不等于
        let cond4 = Condition("amount", "!=", PropertyValue(1000.0))
        assert(order.matches(cond4), "金额 1200.0 != 1000.0 应匹配")

        // 测试大于等于
        let cond5 = Condition("amount", ">=", PropertyValue(1200.0))
        assert(order.matches(cond5), "金额 1200.0 >= 1200.0 应匹配")

        // 测试小于等于
        let cond6 = Condition("amount", "<=", PropertyValue(1200.0))
        assert(order.matches(cond6), "金额 1200.0 <= 1200.0 应匹配")

        // 测试不匹配
        let cond7 = Condition("amount", ">", PropertyValue(1500.0))
        assert(!order.matches(cond7), "金额 1200.0 > 1500.0 不应匹配")

        println("")
    }

    /**
     * 测试 OrderFact 商品数条件
     */
    private func testOrderFactItemsConditions() {
        println("🧪 测试: OrderFact 商品数条件匹配")

        let order = OrderFact("ORDER-002", "普通", 800.0, 15)

        // 测试大于
        let cond1 = Condition("items", ">", PropertyValue(10))
        assert(order.matches(cond1), "商品数 15 > 10 应匹配")

        // 测试小于
        let cond2 = Condition("items", "<", PropertyValue(20))
        assert(order.matches(cond2), "商品数 15 < 20 应匹配")

        // 测试等于
        let cond3 = Condition("items", "=", PropertyValue(15))
        assert(order.matches(cond3), "商品数 15 = 15 应匹配")

        // 测试不匹配
        let cond4 = Condition("items", ">", PropertyValue(20))
        assert(!order.matches(cond4), "商品数 15 > 20 不应匹配")

        println("")
    }

    /**
     * 测试 OrderFact 客户类型条件
     */
    private func testOrderFactCustomerConditions() {
        println("🧪 测试: OrderFact 客户类型条件匹配")

        let vipOrder = OrderFact("ORDER-003", "VIP", 2000.0, 8)
        let normalOrder = OrderFact("ORDER-004", "普通", 500.0, 2)

        // 测试 VIP 匹配
        let cond1 = Condition("customer", "=", PropertyValue("VIP"))
        assert(vipOrder.matches(cond1), "VIP 客户应匹配 VIP 条件")
        assert(!normalOrder.matches(cond1), "普通客户不应匹配 VIP 条件")

        // 测试普通客户匹配
        let cond2 = Condition("customer", "=", PropertyValue("普通"))
        assert(normalOrder.matches(cond2), "普通客户应匹配普通条件")
        assert(!vipOrder.matches(cond2), "VIP 客户不应匹配普通条件")

        // 测试不等于
        let cond3 = Condition("customer", "!=", PropertyValue("VIP"))
        assert(normalOrder.matches(cond3), "普通客户 != VIP 应匹配")

        println("")
    }

    /**
     * 测试 ProductFact 创建
     */
    private func testProductFactCreation() {
        println("🧪 测试: ProductFact 创建")

        let product = ProductFact("PROD-001", "iPhone 15 Pro", 7999.0, 50)

        assertEquals("Product", product.type, "类型应为 Product")
        assertEquals("PROD-001", product.id, "ID 应正确")
        assertEquals("iPhone 15 Pro", product.name, "名称应正确")
        assertEquals(7999.0, product.price, "价格应为 7999.0")
        assertEquals(50, product.stock, "库存应为 50")

        println("")
    }

    /**
     * 测试 ProductFact 价格条件
     */
    private func testProductFactPriceConditions() {
        println("🧪 测试: ProductFact 价格条件匹配")

        let product = ProductFact("PROD-002", "小米手机", 2999.0, 100)

        // 高价产品标记
        let cond1 = Condition("price", ">", PropertyValue(5000.0))
        assert(!product.matches(cond1), "价格 2999.0 > 5000.0 不应匹配")

        let highPriceProduct = ProductFact("PROD-003", "华为手机", 6999.0, 30)
        assert(highPriceProduct.matches(cond1), "价格 6999.0 > 5000.0 应匹配")

        println("")
    }

    /**
     * 测试 ProductFact 库存条件
     */
    private func testProductFactStockConditions() {
        println("🧪 测试: ProductFact 库存条件匹配")

        let product = ProductFact("PROD-004", "MacBook Pro", 15999.0, 5)

        // 低库存警告
        let cond1 = Condition("stock", "<", PropertyValue(10))
        assert(product.matches(cond1), "库存 5 < 10 应匹配(低库存)")

        // 正常库存
        let cond2 = Condition("stock", ">=", PropertyValue(10))
        assert(!product.matches(cond2), "库存 5 >= 10 不应匹配")

        let normalStock = ProductFact("PROD-005", "iPad", 3999.0, 50)
        assert(normalStock.matches(cond2), "库存 50 >= 10 应匹配")

        println("")
    }

    /**
     * 测试 CustomerFact 创建
     */
    private func testCustomerFactCreation() {
        println("🧪 测试: CustomerFact 创建")

        let customer = CustomerFact("CUST-001", "张三", "金卡", 5000, 20)

        assertEquals("Customer", customer.type, "类型应为 Customer")
        assertEquals("CUST-001", customer.id, "ID 应正确")
        assertEquals("张三", customer.name, "姓名应正确")
        assertEquals("金卡", customer.level, "等级应为金卡")
        assertEquals(5000, customer.points, "积分应为 5000")
        assertEquals(20, customer.totalOrders, "订单数应为 20")

        println("")
    }

    /**
     * 测试 CustomerFact 等级条件
     */
    private func testCustomerFactLevelConditions() {
        println("🧪 测试: CustomerFact 等级条件匹配")

        let vip = CustomerFact("CUST-002", "李四", "钻石", 10000, 50)
        let normal = CustomerFact("CUST-003", "王五", "普通", 500, 3)

        // VIP 等级匹配
        let cond1 = Condition("level", "=", PropertyValue("钻石"))
        assert(vip.matches(cond1), "钻石客户应匹配钻石条件")
        assert(!normal.matches(cond1), "普通客户不应匹配钻石条件")

        // 非钻石客户
        let cond2 = Condition("level", "!=", PropertyValue("钻石"))
        assert(normal.matches(cond2), "普通客户 != 钻石 应匹配")

        println("")
    }

    /**
     * 测试 CustomerFact 积分条件
     */
    private func testCustomerFactPointsConditions() {
        println("🧪 测试: CustomerFact 积分条件匹配")

        let customer = CustomerFact("CUST-004", "赵六", "金卡", 8000, 15)

        // 高积分客户
        let cond1 = Condition("points", ">=", PropertyValue(5000))
        assert(customer.matches(cond1), "积分 8000 >= 5000 应匹配")

        // 低积分客户
        let cond2 = Condition("points", "<", PropertyValue(1000))
        assert(!customer.matches(cond2), "积分 8000 < 1000 不应匹配")

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
 * 主函数 - 运行 Fact 测试
 */
main() {
    let test = FactTest()
    let success = test.runAll()

    if (success) {
        println("\n🎉 所有测试通过!")
        System.exit(0)
    } else {
        println("\n⚠️ 存在失败的测试!")
        System.exit(1)
    }
}
