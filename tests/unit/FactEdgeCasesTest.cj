/*
 * Drools4Cj - 单元测试
 * 文件: FactEdgeCasesTest.cj
 * 说明: 测试 Fact 子类的边界情况,包含缺失操作符覆盖和未知字段/操作符处理
 */

package tests.unit

import core.*
import core.OrderFact
import core.ProductFact
import core.CustomerFact
import core.Condition
import core.PropertyValue
import std.collection.ArrayList

/**
 * Fact 子类边界情况测试
 */
class FactEdgeCasesTest {
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
        println("║      Fact 子类边界情况测试                           ║")
        println("╚══════════════════════════════════════════════════════╝\n")

        // OrderFact 边界测试
        testOrderFactItemsAllOperators()
        testOrderFactAmountEdgeCases()
        testOrderFactUnknownField()
        testOrderFactAmountUnknownOperator()
        testOrderFactItemsUnknownOperator()
        testOrderFactCustomerUnknownOperator()

        // ProductFact 边界测试
        testProductFactPriceAllOperators()
        testProductFactStockAllOperators()
        testProductFactUnknownField()
        testProductFactUnknownOperator()

        // CustomerFact 边界测试
        testCustomerFactTotalOrdersAllOperators()
        testCustomerFactPointsAllOperators()
        testCustomerFactLevelOperators()
        testCustomerFactUnknownField()
        testCustomerFactLevelUnknownOperator()

        // toString 方法
        testOrderFactToString()
        testProductFactToString()
        testCustomerFactToString()

        printResults()
        return failed == 0
    }

    // ==================== OrderFact 边界测试 ====================

    /**
     * 测试 OrderFact items 字段全部操作符
     * 现有测试缺少 !=、>=、<= 操作符覆盖
     */
    private func testOrderFactItemsAllOperators() {
        println("🧪 测试: OrderFact items 全操作符覆盖")

        let order = OrderFact("ORDER-A01", "普通", 500.0, 10)

        // 已有测试覆盖: >, <, =
        // 补充: !=, >=, <=

        // 不等于
        let condNe = Condition("items", "!=", PropertyValue(5))
        assert(order.matches(condNe), "商品数 10 != 5 应匹配")

        let condNeEqual = Condition("items", "!=", PropertyValue(10))
        assert(!order.matches(condNeEqual), "商品数 10 != 10 不应匹配")

        // 大于等于
        let condGe = Condition("items", ">=", PropertyValue(10))
        assert(order.matches(condGe), "商品数 10 >= 10 应匹配")

        let condGe2 = Condition("items", ">=", PropertyValue(11))
        assert(!order.matches(condGe2), "商品数 10 >= 11 不应匹配")

        // 小于等于
        let condLe = Condition("items", "<=", PropertyValue(10))
        assert(order.matches(condLe), "商品数 10 <= 10 应匹配")

        let condLe2 = Condition("items", "<=", PropertyValue(9))
        assert(!order.matches(condLe2), "商品数 10 <= 9 不应匹配")

        println("")
    }

    /**
     * 测试 OrderFact amount 边界值
     */
    private func testOrderFactAmountEdgeCases() {
        println("🧪 测试: OrderFact amount 边界值")

        let order = OrderFact("ORDER-A02", "普通", 1000.0, 5)

        // 精确边界: > 等于不匹配, >= 等于匹配
        let condGt = Condition("amount", ">", PropertyValue(1000.0))
        assert(!order.matches(condGt), "金额 1000.0 > 1000.0 不应匹配(严格大于)")

        let condGe = Condition("amount", ">=", PropertyValue(1000.0))
        assert(order.matches(condGe), "金额 1000.0 >= 1000.0 应匹配")

        // 精确边界: < 等于不匹配, <= 等于匹配
        let condLt = Condition("amount", "<", PropertyValue(1000.0))
        assert(!order.matches(condLt), "金额 1000.0 < 1000.0 不应匹配(严格小于)")

        let condLe = Condition("amount", "<=", PropertyValue(1000.0))
        assert(order.matches(condLe), "金额 1000.0 <= 1000.0 应匹配")

        println("")
    }

    /**
     * 测试 OrderFact 未知字段返回 false
     */
    private func testOrderFactUnknownField() {
        println("🧪 测试: OrderFact 未知字段返回 false")

        let order = OrderFact("ORDER-A03", "VIP", 2000.0, 8)

        let condUnknown = Condition("unknownField", ">", PropertyValue(100.0))
        assert(!order.matches(condUnknown), "未知字段应返回 false")

        let condEmpty = Condition("", ">", PropertyValue(100.0))
        assert(!order.matches(condEmpty), "空字段名应返回 false")

        println("")
    }

    /**
     * 测试 OrderFact amount 字段未知操作符返回 false
     */
    private func testOrderFactAmountUnknownOperator() {
        println("🧪 测试: OrderFact amount 未知操作符返回 false")

        let order = OrderFact("ORDER-A04", "普通", 1000.0, 5)

        let condUnknown = Condition("amount", "LIKE", PropertyValue(1000.0))
        assert(!order.matches(condUnknown), "未知操作符 LIKE 应返回 false")

        let condEmpty = Condition("amount", "", PropertyValue(1000.0))
        assert(!order.matches(condEmpty), "空操作符应返回 false")

        println("")
    }

    /**
     * 测试 OrderFact items 字段未知操作符返回 false
     */
    private func testOrderFactItemsUnknownOperator() {
        println("🧪 测试: OrderFact items 未知操作符返回 false")

        let order = OrderFact("ORDER-A05", "普通", 1000.0, 5)

        let condUnknown = Condition("items", "IN", PropertyValue(5))
        assert(!order.matches(condUnknown), "items 未知操作符 IN 应返回 false")

        println("")
    }

    /**
     * 测试 OrderFact customer 字段未知操作符返回 false
     */
    private func testOrderFactCustomerUnknownOperator() {
        println("🧪 测试: OrderFact customer 未知操作符返回 false")

        let order = OrderFact("ORDER-A06", "VIP", 1000.0, 5)

        // customer 字段只支持 = 和 !=,不支持 >
        let condUnknown = Condition("customer", ">", PropertyValue("VIP"))
        assert(!order.matches(condUnknown), "customer 字段不支持 > 操作符应返回 false")

        println("")
    }

    // ==================== ProductFact 边界测试 ====================

    /**
     * 测试 ProductFact price 字段全部操作符
     * 现有测试只覆盖了 > 操作符
     */
    private func testProductFactPriceAllOperators() {
        println("🧪 测试: ProductFact price 全操作符覆盖")

        let product = ProductFact("PROD-B01", "测试产品", 5000.0, 50)

        // 小于
        let condLt = Condition("price", "<", PropertyValue(6000.0))
        assert(product.matches(condLt), "价格 5000.0 < 6000.0 应匹配")

        let condLtNo = Condition("price", "<", PropertyValue(4000.0))
        assert(!product.matches(condLtNo), "价格 5000.0 < 4000.0 不应匹配")

        // 大于等于
        let condGe = Condition("price", ">=", PropertyValue(5000.0))
        assert(product.matches(condGe), "价格 5000.0 >= 5000.0 应匹配")

        let condGeNo = Condition("price", ">=", PropertyValue(5001.0))
        assert(!product.matches(condGeNo), "价格 5000.0 >= 5001.0 不应匹配")

        // 小于等于
        let condLe = Condition("price", "<=", PropertyValue(5000.0))
        assert(product.matches(condLe), "价格 5000.0 <= 5000.0 应匹配")

        let condLeNo = Condition("price", "<=", PropertyValue(4999.0))
        assert(!product.matches(condLeNo), "价格 5000.0 <= 4999.0 不应匹配")

        // 等于
        let condEq = Condition("price", "=", PropertyValue(5000.0))
        assert(product.matches(condEq), "价格 5000.0 = 5000.0 应匹配")

        let condEqNo = Condition("price", "=", PropertyValue(4999.0))
        assert(!product.matches(condEqNo), "价格 5000.0 = 4999.0 不应匹配")

        println("")
    }

    /**
     * 测试 ProductFact stock 字段全部操作符
     * 现有测试缺少 >、<=、= 操作符覆盖
     */
    private func testProductFactStockAllOperators() {
        println("🧪 测试: ProductFact stock 全操作符覆盖")

        let product = ProductFact("PROD-B02", "高库存产品", 999.0, 100)

        // 大于
        let condGt = Condition("stock", ">", PropertyValue(50))
        assert(product.matches(condGt), "库存 100 > 50 应匹配")

        let condGtNo = Condition("stock", ">", PropertyValue(100))
        assert(!product.matches(condGtNo), "库存 100 > 100 不应匹配(严格大于)")

        // 小于等于
        let condLe = Condition("stock", "<=", PropertyValue(100))
        assert(product.matches(condLe), "库存 100 <= 100 应匹配")

        let condLeNo = Condition("stock", "<=", PropertyValue(99))
        assert(!product.matches(condLeNo), "库存 100 <= 99 不应匹配")

        // 等于
        let condEq = Condition("stock", "=", PropertyValue(100))
        assert(product.matches(condEq), "库存 100 = 100 应匹配")

        let condEqNo = Condition("stock", "=", PropertyValue(99))
        assert(!product.matches(condEqNo), "库存 100 = 99 不应匹配")

        println("")
    }

    /**
     * 测试 ProductFact 未知字段返回 false
     */
    private func testProductFactUnknownField() {
        println("🧪 测试: ProductFact 未知字段返回 false")

        let product = ProductFact("PROD-B03", "测试", 1000.0, 20)

        let condUnknown = Condition("category", "=", PropertyValue("Electronics"))
        assert(!product.matches(condUnknown), "ProductFact 未知字段应返回 false")

        let condName = Condition("name", "=", PropertyValue("测试"))
        assert(!product.matches(condName), "ProductFact name 字段(未实现)应返回 false")

        println("")
    }

    /**
     * 测试 ProductFact 未知操作符返回 false
     */
    private func testProductFactUnknownOperator() {
        println("🧪 测试: ProductFact 未知操作符返回 false")

        let product = ProductFact("PROD-B04", "测试", 1000.0, 20)

        // price 不支持 !=
        let condNe = Condition("price", "!=", PropertyValue(500.0))
        assert(!product.matches(condNe), "ProductFact price 不支持 != 操作符应返回 false")

        // stock 不支持 !=
        let condStockNe = Condition("stock", "!=", PropertyValue(10))
        assert(!product.matches(condStockNe), "ProductFact stock 不支持 != 操作符应返回 false")

        println("")
    }

    // ==================== CustomerFact 边界测试 ====================

    /**
     * 测试 CustomerFact totalOrders 字段 - 现有测试完全未覆盖
     */
    private func testCustomerFactTotalOrdersAllOperators() {
        println("🧪 测试: CustomerFact totalOrders 全操作符覆盖")

        let customer = CustomerFact("CUST-C01", "测试客户", "金卡", 3000, 25)

        // 大于
        let condGt = Condition("totalOrders", ">", PropertyValue(20))
        assert(customer.matches(condGt), "订单数 25 > 20 应匹配")

        let condGtNo = Condition("totalOrders", ">", PropertyValue(25))
        assert(!customer.matches(condGtNo), "订单数 25 > 25 不应匹配(严格大于)")

        // 小于
        let condLt = Condition("totalOrders", "<", PropertyValue(30))
        assert(customer.matches(condLt), "订单数 25 < 30 应匹配")

        let condLtNo = Condition("totalOrders", "<", PropertyValue(20))
        assert(!customer.matches(condLtNo), "订单数 25 < 20 不应匹配")

        // 大于等于
        let condGe = Condition("totalOrders", ">=", PropertyValue(25))
        assert(customer.matches(condGe), "订单数 25 >= 25 应匹配")

        let condGeNo = Condition("totalOrders", ">=", PropertyValue(26))
        assert(!customer.matches(condGeNo), "订单数 25 >= 26 不应匹配")

        // 小于等于
        let condLe = Condition("totalOrders", "<=", PropertyValue(25))
        assert(customer.matches(condLe), "订单数 25 <= 25 应匹配")

        let condLeNo = Condition("totalOrders", "<=", PropertyValue(24))
        assert(!customer.matches(condLeNo), "订单数 25 <= 24 不应匹配")

        println("")
    }

    /**
     * 测试 CustomerFact points 字段补充操作符
     * 现有测试缺少 >、<=、= 操作符覆盖
     */
    private func testCustomerFactPointsAllOperators() {
        println("🧪 测试: CustomerFact points 补充操作符覆盖")

        let customer = CustomerFact("CUST-C02", "积分客户", "银卡", 3000, 15)

        // 大于(缺失覆盖)
        let condGt = Condition("points", ">", PropertyValue(2000))
        assert(customer.matches(condGt), "积分 3000 > 2000 应匹配")

        let condGtNo = Condition("points", ">", PropertyValue(3000))
        assert(!customer.matches(condGtNo), "积分 3000 > 3000 不应匹配(严格大于)")

        // 小于等于(缺失覆盖)
        let condLe = Condition("points", "<=", PropertyValue(3000))
        assert(customer.matches(condLe), "积分 3000 <= 3000 应匹配")

        let condLeNo = Condition("points", "<=", PropertyValue(2999))
        assert(!customer.matches(condLeNo), "积分 3000 <= 2999 不应匹配")

        // 等于(缺失覆盖 - CustomerFact points 未实现 =)
        let condEq = Condition("points", "=", PropertyValue(3000))
        assert(!customer.matches(condEq), "CustomerFact points 不支持 = 操作符应返回 false")

        println("")
    }

    /**
     * 测试 CustomerFact level 字段操作符覆盖
     */
    private func testCustomerFactLevelOperators() {
        println("🧪 测试: CustomerFact level 操作符覆盖")

        let gold = CustomerFact("CUST-C03", "金卡客户", "金卡", 5000, 20)
        let silver = CustomerFact("CUST-C04", "银卡客户", "银卡", 1500, 8)

        // 等于
        let condEqGold = Condition("level", "=", PropertyValue("金卡"))
        assert(gold.matches(condEqGold), "金卡客户应匹配金卡条件")
        assert(!silver.matches(condEqGold), "银卡客户不应匹配金卡条件")

        // 不等于
        let condNeGold = Condition("level", "!=", PropertyValue("金卡"))
        assert(!gold.matches(condNeGold), "金卡客户不应匹配不等于金卡条件")
        assert(silver.matches(condNeGold), "银卡客户应匹配不等于金卡条件")

        println("")
    }

    /**
     * 测试 CustomerFact 未知字段返回 false
     */
    private func testCustomerFactUnknownField() {
        println("🧪 测试: CustomerFact 未知字段返回 false")

        let customer = CustomerFact("CUST-C05", "测试", "普通", 100, 2)

        let condUnknown = Condition("email", "=", PropertyValue("test@example.com"))
        assert(!customer.matches(condUnknown), "CustomerFact 未知字段应返回 false")

        let condName = Condition("name", "=", PropertyValue("测试"))
        assert(!customer.matches(condName), "CustomerFact name 字段(未实现)应返回 false")

        println("")
    }

    /**
     * 测试 CustomerFact level 字段未知操作符返回 false
     */
    private func testCustomerFactLevelUnknownOperator() {
        println("🧪 测试: CustomerFact level 未知操作符返回 false")

        let customer = CustomerFact("CUST-C06", "测试", "金卡", 5000, 20)

        // level 只支持 = 和 !=,不支持 >
        let condGt = Condition("level", ">", PropertyValue("银卡"))
        assert(!customer.matches(condGt), "CustomerFact level 不支持 > 操作符应返回 false")

        println("")
    }

    // ==================== toString 方法测试 ====================

    /**
     * 测试 OrderFact toString
     */
    private func testOrderFactToString() {
        println("🧪 测试: OrderFact toString")

        let order = OrderFact("ORDER-T01", "VIP", 2500.0, 12)
        let str = order.toString()

        assert(str.contains("ORDER-T01"), "toString 应包含 id")
        assert(str.contains("VIP"), "toString 应包含客户类型")
        assert(str.contains("2500"), "toString 应包含金额")
        assert(str.contains("12"), "toString 应包含商品数")

        println("")
    }

    /**
     * 测试 ProductFact toString
     */
    private func testProductFactToString() {
        println("🧪 测试: ProductFact toString")

        let product = ProductFact("PROD-T01", "iPhone 16", 8999.0, 30)
        let str = product.toString()

        assert(str.contains("PROD-T01"), "toString 应包含 id")
        assert(str.contains("iPhone 16"), "toString 应包含产品名")
        assert(str.contains("8999"), "toString 应包含价格")
        assert(str.contains("30"), "toString 应包含库存")

        println("")
    }

    /**
     * 测试 CustomerFact toString
     */
    private func testCustomerFactToString() {
        println("🧪 测试: CustomerFact toString")

        let customer = CustomerFact("CUST-T01", "张伟", "钻石", 15000, 60)
        let str = customer.toString()

        assert(str.contains("CUST-T01"), "toString 应包含 id")
        assert(str.contains("张伟"), "toString 应包含姓名")
        assert(str.contains("钻石"), "toString 应包含等级")
        assert(str.contains("15000"), "toString 应包含积分")
        assert(str.contains("60"), "toString 应包含订单数")

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
 * 主函数 - 运行 Fact 边界情况测试
 */
main() {
    let test = FactEdgeCasesTest()
    let success = test.runAll()

    if (success) {
        println("\n🎉 所有测试通过!")
        System.exit(0)
    } else {
        println("\n⚠️ 存在失败的测试!")
        System.exit(1)
    }
}
