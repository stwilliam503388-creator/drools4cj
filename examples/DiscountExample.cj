/*
 * Drools 规则引擎 - 仓颉实现
 * 示例 1: 订单折扣规则
 * 演示基本的规则引擎使用
 */

package examples

import core.*
import core.RuleEngine
import core.RuleBuilder
import core.OrderFact
import core.PropertyValue

main() {
    println("╔══════════════════════════════════════════════════════╗")
    println("║     订单折扣规则示例 - Drools 仓颉实现              ║")
    println("╚══════════════════════════════════════════════════════╝")
    println("")

    // 1. 创建规则引擎
    let engine = RuleEngineBuilder()
        .enableLog(true)
        .enableStats(true)
        .build()

    // 2. 定义折扣规则
    println("📝 定义业务规则...")
    println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

    // 规则1: 订单金额 > 1000, 打 9 折
    engine.addRule(
        RuleBuilder("订单金额折扣_9折")
            .description("订单金额超过 1000 元,享受 9 折优惠")
            .salience(100)  // 高优先级
            .when("amount", ">", PropertyValue(1000.0))
            .then({
                println("    ✨ 规则触发: 订单金额超过 1000,享受 9 折优惠!")
                println("    💰 优惠金额: ${(1000.0 * 0.1).toFixed(2)} 元")
            })
            .build()
    )

    // 规则2: 订单商品数 > 10, 打 8.5 折
    engine.addRule(
        RuleBuilder("订单商品数折扣_85折")
            .description("订单商品数超过 10 件,享受 8.5 折优惠")
            .salience(90)
            .when("items", ">", PropertyValue(10))
            .then({
                println("    ✨ 规则触发: 订单商品数超过 10,享受 8.5 折优惠!")
                println("    📦 批量购买折扣已应用")
            })
            .build()
    )

    // 规则3: VIP 客户,额外 95 折
    engine.addRule(
        RuleBuilder("VIP客户额外折扣_95折")
            .description("VIP 客户,额外享受 95 折优惠")
            .salience(80)
            .when("customer", "=", PropertyValue("VIP"))
            .then({
                println("    ✨ 规则触发: VIP 客户,额外享受 95 折优惠!")
                println("    👑 VIP 专享优惠已应用")
            })
            .build()
    )

    // 规则4: 普通客户小额订单,不予折扣
    engine.addRule(
        RuleBuilder("小额订单无折扣")
            .description("普通客户,订单金额 < 500,无折扣")
            .salience(50)
            .when("customer", "=", PropertyValue("普通"))
            .when("amount", "<", PropertyValue(500.0))
            .then({
                println("    ℹ️  规则触发: 小额订单,暂无折扣优惠")
                println("    💡 提示: 满额 1000 元可享受折扣")
            })
            .build()
    )

    println("✅ 共定义 ${engine.getRules().size} 条规则\n")

    // 3. 插入订单事实
    println("📦 插入订单事实...")
    println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

    // 订单1: 普通客户,金额 1200,5 件商品 → 应触发规则1
    println("\n订单 1: 普通客户,金额 1200 元,5 件商品")
    engine.insert(OrderFact(
        "ORDER-001",
        "普通",
        1200.0,
        5
    ))

    // 订单2: VIP 客户,金额 800,15 件商品 → 应触发规则2和规则3
    println("订单 2: VIP 客户,金额 800 元,15 件商品")
    engine.insert(OrderFact(
        "ORDER-002",
        "VIP",
        800.0,
        15
    ))

    // 订单3: 普通客户,金额 1500,12 件商品 → 应触发规则1和规则2
    println("订单 3: 普通客户,金额 1500 元,12 件商品")
    engine.insert(OrderFact(
        "ORDER-003",
        "普通",
        1500.0,
        12
    ))

    // 订单4: 普通客户,金额 300,2 件商品 → 应触发规则4
    println("订单 4: 普通客户,金额 300 元,2 件商品")
    engine.insert(OrderFact(
        "ORDER-004",
        "普通",
        300.0,
        2
    ))

    // 订单5: VIP 客户,金额 2000,8 件商品 → 应触发规则1和规则3
    println("订单 5: VIP 客户,金额 2000 元,8 件商品")
    engine.insert(OrderFact(
        "ORDER-005",
        "VIP",
        2000.0,
        8
    ))

    // 4. 打印引擎状态
    println("")
    engine.printStatus()

    // 5. 执行规则
    println("\n🔥 执行规则...")
    println("══════════════════════════════════")
    engine.fireAllRules()
    println("══════════════════════════════════")

    // 6. 显示最终统计
    println("\n📊 最终统计:")
    println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    println(engine.getStats().toString())
    println(engine.getWorkingMemory().getStats())

    println("\n✅ 示例完成!")
    println("\n💡 关键要点:")
    println("  • 规则按优先级(salience)排序执行")
    println("  • 一个订单可以触发多条规则")
    println("  • 工作内存自动维护所有事实")
    println("  • 议程管理规则执行顺序")
}
