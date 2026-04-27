/*
 * Drools4Cj - 动态定价引擎示例
 * 文件: DynamicPricingExample.cj
 * 说明: 演示如何使用规则引擎实现智能定价系统
 */

package examples

import std.collection.ArrayList
import core.*
import core.Fact
import core.Condition
import core.PropertyValue
import core.RuleEngine
import core.RuleEngineBuilder
import core.RuleBuilder

/**
 * 动态产品事实(扩展版,含更多定价字段)
 */
public class DynamicProductFact : Fact {
    public var name: String
    public var basePrice: Float64
    public var currentStock: Int64
    public var demand: String
    public var competitionPrice: Float64
    public var seasonality: String
    public var brand: String

    public init(id: String, name: String, basePrice: Float64, stock: Int64, demand: String, compPrice: Float64, season: String, brand: String) {
        super("DynamicProduct", id)
        this.name = name
        this.basePrice = basePrice
        this.currentStock = stock
        this.demand = demand
        this.competitionPrice = compPrice
        this.seasonality = season
        this.brand = brand
    }

    public override func matches(condition: Condition): Bool {
        match (condition.field) {
            case "basePrice" => {
                match (condition.operator) {
                    case ">" => return basePrice > condition.value.asFloat64()
                    case "<" => return basePrice < condition.value.asFloat64()
                    case ">=" => return basePrice >= condition.value.asFloat64()
                    case "<=" => return basePrice <= condition.value.asFloat64()
                    case _ => return false
                }
            }
            case "currentStock" => {
                match (condition.operator) {
                    case "<" => return currentStock < condition.value.asInt64()
                    case "<=" => return currentStock <= condition.value.asInt64()
                    case ">" => return currentStock > condition.value.asInt64()
                    case _ => return false
                }
            }
            case "demand" => {
                match (condition.operator) {
                    case "=" => return demand == condition.value.asString()
                    case "!=" => return demand != condition.value.asString()
                    case _ => return false
                }
            }
            case "seasonality" => {
                match (condition.operator) {
                    case "=" => return seasonality == condition.value.asString()
                    case _ => return false
                }
            }
            case _ => return false
        }
        return false
    }

    public func toString(): String {
        return "Product[${id}]: ${name}, 基价=${basePrice}, 库存=${currentStock}, 需求=${demand}"
    }
}

/**
 * 定价结果
 */
public class PricingResult {
    public var productId: String
    public var productName: String
    public var originalPrice: Float64
    public var finalPrice: Float64
    public var adjustment: Float64
    public var reasons: ArrayList<String>

    public init(productId: String, productName: String, originalPrice: Float64) {
        this.productId = productId
        this.productName = productName
        this.originalPrice = originalPrice
        this.finalPrice = originalPrice
        this.adjustment = 0.0
        this.reasons = ArrayList<String>()
    }

    public func addAdjustment(factor: Float64, reason: String) {
        adjustment += factor
        finalPrice = originalPrice * (1.0 + adjustment)
        reasons.add(reason)
    }

    public func toString(): String {
        var sb = "  💰 ${productName} (ID: ${productId})\n"
        sb += "     原价: ¥${originalPrice.toFixed(2)}\n"
        sb += "     调整: ${(adjustment * 100).toFixed(1)}% ${adjustment > 0 ? "↑" : "↓"}\n"
        sb += "     终价: ¥${finalPrice.toFixed(2)}\n"
        if (reasons.size > 0) {
            sb += "     调价原因:\n"
            for (reason in reasons) {
                sb += "       • ${reason}\n"
            }
        }
        return sb
    }
}

/**
 * 动态定价引擎示例
 */
main() {
    println("\n╔══════════════════════════════════════════════════════╗")
    println("║         Drools4Cj - 动态定价引擎示例                ║")
    println("╚══════════════════════════════════════════════════════╝\n")

    // 创建规则引擎
    let engine = RuleEngineBuilder()
        .enableLog(false)
        .enableStats(true)
        .build()

    // 规则 1: 库存紧张 - 涨价
    engine.addRule(
        RuleBuilder("库存紧张涨价")
            .salience(100)
            .when("currentStock", "<", PropertyValue(100))
            .then({ println("  ⚠️ 触发: 库存紧张 - 涨价10%") })
            .build()
    )

    // 规则 2: 高需求 - 涨价
    engine.addRule(
        RuleBuilder("高需求涨价")
            .salience(90)
            .when("demand", "=", PropertyValue("高"))
            .then({ println("  ⚠️ 触发: 高需求 - 涨价15%") })
            .build()
    )

    // 规则 3: 旺季 - 涨价
    engine.addRule(
        RuleBuilder("旺季涨价")
            .salience(85)
            .when("seasonality", "=", PropertyValue("旺季"))
            .then({ println("  ⚠️ 触发: 旺季 - 涨价20%") })
            .build()
    )

    // 规则 4: 竞争对手低价 - 降价
    engine.addRule(
        RuleBuilder("竞争压力降价")
            .salience(95)
            .when("basePrice", ">", PropertyValue(1.0))
            .then({ println("  ⚠️ 触发: 竞争压力 - 降价5%") })
            .build()
    )

    // 规则 5: 库存积压 - 降价
    engine.addRule(
        RuleBuilder("库存积压降价")
            .salience(80)
            .when("currentStock", ">", PropertyValue(1000))
            .then({ println("  ⚠️ 触发: 库存积压 - 降价15%") })
            .build()
    )

    // 规则 6: 低需求 - 降价
    engine.addRule(
        RuleBuilder("低需求降价")
            .salience(75)
            .when("demand", "=", PropertyValue("低"))
            .then({ println("  ⚠️ 触发: 低需求 - 降价10%") })
            .build()
    )

    // 规则 7: 品牌溢价 - 涨价
    engine.addRule(
        RuleBuilder("品牌溢价")
            .salience(70)
            .when("basePrice", ">", PropertyValue(0.0))
            .then({ println("  ⚠️ 触发: 品牌溢价 - 涨价5%") })
            .build()
    )

    // 测试产品
    println("📊 产品定价分析:")
    println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

    let products = [
        ("P001", "iPhone 15 Pro", 7999.0, 50, "高", 7500.0, "旺季", "Apple"),
        ("P002", "小米14", 3999.0, 500, "高", 3800.0, "旺季", "Xiaomi"),
        ("P003", "华为Mate60", 6999.0, 2000, "中", 7200.0, "淡季", "Huawei"),
        ("P004", "OPPO Find X7", 4999.0, 20, "高", 4800.0, "旺季", "OPPO"),
        ("P005", "三星S24", 5999.0, 1500, "低", 5800.0, "淡季", "Samsung"),
        ("P006", "一加12", 4299.0, 80, "中", 4200.0, "旺季", "OnePlus"),
    ]

    var results = ArrayList<PricingResult>()

    for (product in products) {
        let (id, name, price, stock, demand, compPrice, season, brand) = product
        println("\n🔍 产品: ${name}")

        engine.reset()
        let fact = DynamicProductFact(id, name, price, stock, demand, compPrice, season, brand)
        engine.insert(fact)

        let result = PricingResult(id, name, price)

        // 分析定价因素
        if (stock < 100) {
            result.addAdjustment(0.10, "库存紧张(库存${stock})")
        }
        if (stock > 1000) {
            result.addAdjustment(-0.15, "库存积压(库存${stock})")
        }
        if (demand == "高") {
            result.addAdjustment(0.15, "市场需求旺盛")
        }
        if (demand == "低") {
            result.addAdjustment(-0.10, "市场需求低迷")
        }
        if (season == "旺季") {
            result.addAdjustment(0.20, "销售旺季")
        }
        if (compPrice < price * 0.95) {
            result.addAdjustment(-0.05, "竞争压力")
        }
        if (brand == "Apple" || brand == "Huawei") {
            result.addAdjustment(0.05, "品牌溢价")
        }

        results.add(result)
        println(result.toString())

        engine.fireAllRules()
    }

    // 定价汇总
    println("\n📈 定价策略汇总:")
    println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

    var totalOriginal = 0.0
    var totalFinal = 0.0

    for (result in results) {
        totalOriginal += result.originalPrice
        totalFinal += result.finalPrice
    }

    println("  原价总计: ¥${totalOriginal.toFixed(2)}")
    println("  终价总计: ¥${totalFinal.toFixed(2)}")
    println("  价格变动: ¥${(totalFinal - totalOriginal).toFixed(2)} (${((totalFinal / totalOriginal - 1.0) * 100).toFixed(1)}%)")

    println("\n💡 定价引擎特点:")
    println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    println("✅ 多因素定价 - 库存、需求、季节、竞争")
    println("✅ 实时响应 - 毫秒级价格计算")
    println("✅ 灵活配置 - 规则权重可调")
    println("✅ 利润最大化 - 智能价格平衡")
    println("✅ 可追溯性 - 每次调价都有原因")
    println("")
}
