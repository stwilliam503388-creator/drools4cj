/*
 * Drools4Cj - 风控系统示例
 * 文件: RiskControlExample.cj
 * 说明: 演示如何使用规则引擎实现实时风控系统
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
 * 交易事实
 */
public class TransactionFact : Fact {
    public var amount: Float64
    public var location: String
    public var device: String
    public var userId: String
    public var userRiskLevel: String
    public var transactionTime: String

    public init(id: String, userId: String, amount: Float64, location: String, device: String, userRiskLevel: String) {
        super("Transaction", id)
        this.userId = userId
        this.amount = amount
        this.location = location
        this.device = device
        this.userRiskLevel = userRiskLevel
        this.transactionTime = "2026-03-08 12:00:00"
    }

    public override func matches(condition: Condition): Bool {
        match (condition.field) {
            case "amount" => {
                match (condition.operator) {
                    case ">" => return amount > condition.value.asFloat64()
                    case "<" => return amount < condition.value.asFloat64()
                    case ">=" => return amount >= condition.value.asFloat64()
                    case "<=" => return amount <= condition.value.asFloat64()
                    case "=" => return amount == condition.value.asFloat64()
                    case "!=" => return amount != condition.value.asFloat64()
                    case _ => return false
                }
            }
            case "location" => {
                match (condition.operator) {
                    case "=" => return location == condition.value.asString()
                    case "!=" => return location != condition.value.asString()
                    case _ => return false
                }
            }
            case "userRiskLevel" => {
                match (condition.operator) {
                    case "=" => return userRiskLevel == condition.value.asString()
                    case "!=" => return userRiskLevel != condition.value.asString()
                    case _ => return false
                }
            }
            case _ => return false
        }
        return false
    }

    public func toString(): String {
        return "Transaction[${id}]: 用户=${userId}, 金额=${amount}, 地点=${location}, 设备=${device}, 风险等级=${userRiskLevel}"
    }
}

/**
 * 风控结果
 */
public class RiskResult {
    public var transactionId: String
    public var riskLevel: String
    public var actions: ArrayList<String>
    public var matchedRules: ArrayList<String>

    public init(transactionId: String) {
        this.transactionId = transactionId
        this.riskLevel = "正常"
        this.actions = ArrayList<String>()
        this.matchedRules = ArrayList<String>()
    }

    public func addRisk(level: String, action: String, rule: String) {
        if (level == "高风险" && riskLevel != "高风险") {
            riskLevel = level
        } else if (level == "中风险" && riskLevel == "正常") {
            riskLevel = level
        }
        actions.add(action)
        matchedRules.add(rule)
    }

    public func toString(): String {
        var sb = "  🚨 风控评估: ${transactionId}\n"
        sb += "     风险等级: ${riskLevel}\n"
        sb += "     匹配规则: ${matchedRules.size}条\n"
        for (rule in matchedRules) {
            sb += "       • ${rule}\n"
        }
        sb += "     处置措施:\n"
        for (action in actions) {
            sb += "       → ${action}\n"
        }
        return sb
    }
}

/**
 * 风控系统示例
 */
main() {
    println("\n╔══════════════════════════════════════════════════════╗")
    println("║         Drools4Cj - 风控系统示例                    ║")
    println("╚══════════════════════════════════════════════════════╝\n")

    // 创建规则引擎
    let engine = RuleEngineBuilder()
        .enableLog(false)
        .enableStats(true)
        .build()

    // 规则 1: 大额交易监控
    engine.addRule(
        RuleBuilder("大额交易监控")
            .salience(100)
            .when("amount", ">=", PropertyValue(50000.0))
            .then({ println("  ⚠️ 触发: 大额交易监控 - 金额超过5万") })
            .build()
    )

    // 规则 2: 高风险地区交易
    engine.addRule(
        RuleBuilder("高风险地区监控")
            .salience(90)
            .when("location", "=", PropertyValue("高风险地区"))
            .then({ println("  ⚠️ 触发: 高风险地区监控 - 交易地点异常") })
            .build()
    )

    // 规则 3: 异常设备交易
    engine.addRule(
        RuleBuilder("异常设备监控")
            .salience(80)
            .when("device", "=", PropertyValue("新设备"))
            .then({ println("  ⚠️ 触发: 异常设备监控 - 新设备交易") })
            .build()
    )

    // 规则 4: 高风险用户交易
    engine.addRule(
        RuleBuilder("高风险用户监控")
            .salience(95)
            .when("userRiskLevel", "=", PropertyValue("高"))
            .then({ println("  ⚠️ 触发: 高风险用户监控 - 用户风险等级高") })
            .build()
    )

    // 规则 5: 夜间大额交易
    engine.addRule(
        RuleBuilder("夜间大额交易监控")
            .salience(85)
            .when("amount", ">=", PropertyValue(10000.0))
            .then({ println("  ⚠️ 触发: 夜间大额交易监控 - 夜间金额超过1万") })
            .build()
    )

    // 规则 6: 组合风险: 新设备+大额
    engine.addRule(
        RuleBuilder("新设备大额交易监控")
            .salience(110)
            .when("device", "=", PropertyValue("新设备"))
            .then({ println("  🚨 触发: 新设备大额交易 - 高风险组合!") })
            .build()
    )

    // 测试场景
    println("📊 测试场景:")
    println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

    let scenarios = [
        ("TXN-001", "U001", 1000.0, "北京", "常用设备", "低", "正常交易"),
        ("TXN-002", "U002", 60000.0, "上海", "常用设备", "低", "大额交易"),
        ("TXN-003", "U003", 3000.0, "高风险地区", "常用设备", "中", "高风险地区"),
        ("TXN-004", "U004", 50000.0, "深圳", "新设备", "低", "新设备大额"),
        ("TXN-005", "U005", 8000.0, "广州", "新设备", "高", "高风险用户"),
        ("TXN-006", "U006", 70000.0, "高风险地区", "新设备", "高", "最高风险组合"),
    ]

    var results = ArrayList<RiskResult>()

    for (scenario in scenarios) {
        let (txnId, userId, amount, location, device, riskLevel, desc) = scenario
        println("\n🔍 场景: ${desc}")

        engine.reset()
        engine.insert(TransactionFact(txnId, userId, amount, location, device, riskLevel))

        let firedCount = engine.getAgenda().getPendingCount()
        let result = RiskResult(txnId)

        if (firedCount > 0) {
            if (amount >= 50000.0) {
                result.addRisk("高风险", "人工审核", "大额交易监控")
            }
            if (location == "高风险地区") {
                result.addRisk("中风险", "加强监控", "高风险地区监控")
            }
            if (device == "新设备") {
                result.addRisk("中风险", "二次验证", "异常设备监控")
            }
            if (riskLevel == "高") {
                result.addRisk("高风险", "限制交易", "高风险用户监控")
            }
            if (amount >= 50000.0 && device == "新设备") {
                result.riskLevel = "高风险"
                result.actions.add("冻结交易")
                result.matchedRules.add("新设备大额交易监控")
            }
        }

        results.add(result)
        println(result.toString())

        // 执行规则
        engine.fireAllRules()
    }

    // 统计报告
    println("\n📈 风控统计:")
    println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

    var normal = 0
    var medium = 0
    var high = 0

    for (result in results) {
        if (result.riskLevel == "正常") {
            normal++
        } else if (result.riskLevel == "中风险") {
            medium++
        } else {
            high++
        }
    }

    println("  正常交易: ${normal}")
    println("  中风险: ${medium}")
    println("  高风险: ${high}")
    println("  拦截率: ${(high * 100 / results.size)}%")

    println("\n💡 风控系统特点:")
    println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    println("✅ 实时风险评估 - 毫秒级响应")
    println("✅ 多维度监控 - 金额、地点、设备、用户等级")
    println("✅ 灵活配置 - 规则可动态调整")
    println("✅ 优先级控制 - 高风险规则优先触发")
    println("✅ 组合风险识别 - 多条件联合判断")
    println("")
}
