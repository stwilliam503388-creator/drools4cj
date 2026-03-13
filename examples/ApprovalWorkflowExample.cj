/*
 * Drools4Cj - 审批流程示例
 * 文件: ApprovalWorkflowExample.cj
 * 说明: 演示如何使用规则引擎实现智能审批流程
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
 * 审批请求事实
 */
public class ApprovalRequest : Fact {
    public var requestType: String
    public var amount: Float64
    public var requesterLevel: String
    public var department: String
    public var urgency: String
    public var attachments: Int64
    public var requestTime: String

    public init(id: String, requestType: String, amount: Float64, level: String, dept: String, urgency: String, attachments: Int64) {
        super("ApprovalRequest", id)
        this.requestType = requestType
        this.amount = amount
        this.requesterLevel = level
        this.department = dept
        this.urgency = urgency
        this.attachments = attachments
        this.requestTime = "2026-03-08 10:00:00"
    }

    public override func matches(condition: Condition): Bool {
        match (condition.field) {
            case "amount" => {
                match (condition.operator) {
                    case ">" => return amount > condition.value.asFloat64()
                    case "<" => return amount < condition.value.asFloat64()
                    case ">=" => return amount >= condition.value.asFloat64()
                    case "<=" => return amount <= condition.value.asFloat64()
                    case _ => return false
                }
            }
            case "requesterLevel" => {
                match (condition.operator) {
                    case "=" => return requesterLevel == condition.value.asString()
                    case "!=" => return requesterLevel != condition.value.asString()
                    case _ => return false
                }
            }
            case "urgency" => {
                match (condition.operator) {
                    case "=" => return urgency == condition.value.asString()
                    case _ => return false
                }
            }
            case "requestType" => {
                match (condition.operator) {
                    case "=" => return requestType == condition.value.asString()
                    case _ => return false
                }
            }
            case _ => return false
        }
        return false
    }

    public func toString(): String {
        return "ApprovalRequest[${id}]: ${requestType}, 金额=${amount}, 申请人等级=${requesterLevel}"
    }
}

/**
 * 审批结果
 */
public class ApprovalResult {
    public var requestId: String
    public var requestType: String
    public var amount: Float64
    public var approvalPath: ArrayList<String>
    public var autoApproved: Bool
    public var rejectReason: String

    public init(requestId: String, requestType: String, amount: Float64) {
        self.requestId = requestId
        self.requestType = requestType
        self.amount = amount
        self.approvalPath = ArrayList<String>()
        self.autoApproved = false
        self.rejectReason = ""
    }

    public func addApprover(role: String) {
        approvalPath.add(role)
    }

    public func setAutoApproved(reason: String) {
        autoApproved = true
        approvalPath.add("系统自动批准: ${reason}")
    }

    public func setRejected(reason: String) {
        rejectReason = reason
    }

    public func toString(): String {
        var sb = "  📝 审批单: ${requestId}\n"
        sb += "     类型: ${requestType}\n"
        sb += "     金额: ¥${amount.toFixed(2)}\n"
        sb += "     审批流程:\n"

        if (autoApproved) {
            sb += "       ✅ ${approvalPath[0]}\n"
        } else if (rejectReason != "") {
            sb += "       ❌ 拒绝: ${rejectReason}\n"
        } else {
            var idx = 0
            for (approver in approvalPath) {
                sb += "       ${idx + 1}. ${approver}\n"
                idx++
            }
        }
        return sb
    }
}

/**
 * 审批流程示例
 */
main() {
    println("\n╔══════════════════════════════════════════════════════╗")
    println("║         Drools4Cj - 智能审批流程示例                ║")
    println("╚══════════════════════════════════════════════════════╝\n")

    // 创建规则引擎
    let engine = RuleEngineBuilder()
        .enableLog(false)
        .enableStats(true)
        .build()

    // 规则 1: 小额采购自动批准
    engine.addRule(
        RuleBuilder("小额采购自动批准")
            .salience(100)
            .when("requestType", "=", PropertyValue("采购申请"))
            .when("amount", "<=", PropertyValue(500.0))
            .then({ println("  ✅ 自动批准: 小额采购") })
            .build()
    )

    // 规则 2: 普通员工需要部门主管审批
    engine.addRule(
        RuleBuilder("普通员工部门审批")
            .salience(90)
            .when("requesterLevel", "=", PropertyValue("普通员工"))
            .then({ println("  📋 需要: 部门主管审批") })
            .build()
    )

    // 规则 3: 中等金额需要部门经理+财务审批
    engine.addRule(
        RuleBuilder("中等金额双重审批")
            .salience(95)
            .when("amount", ">", PropertyValue(5000.0))
            .when("amount", "<=", PropertyValue(20000.0))
            .then({ println("  📋 需要: 部门经理+财务审批") })
            .build()
    )

    // 规则 4: 大额金额需要多级审批
    engine.addRule(
        RuleBuilder("大额金额多级审批")
            .salience(110)
            .when("amount", ">", PropertyValue(20000.0))
            .then({ println("  📋 需要: 部门经理+财务总监+副总审批") })
            .build()
    )

    // 规则 5: 超大额需要CEO审批
    engine.addRule(
        RuleBuilder("超大额CEO审批")
            .salience(120)
            .when("amount", ">=", PropertyValue(100000.0))
            .then({ println("  📋 需要: CEO最终审批") })
            .build()
    )

    // 规则 6: 紧急申请快速通道
    engine.addRule(
        RuleBuilder("紧急申请快速通道")
            .salience(105)
            .when("urgency", "=", PropertyValue("紧急"))
            .then({ println("  ⚡ 快速通道: 加急处理") })
            .build()
    )

    // 规则 7: 缺少附件拒绝
    engine.addRule(
        RuleBuilder("缺少附件拒绝")
            .salience(130)
            .when("attachments", "=", PropertyValue(0))
            .then({ println("  ❌ 拒绝: 缺少必要附件") })
            .build()
    )

    // 规则 8: 管理层简化流程
    engine.addRule(
        RuleBuilder("管理层简化流程")
            .salience(115)
            .when("requesterLevel", "=", PropertyValue("管理层"))
            .when("amount", "<=", PropertyValue(10000.0))
            .then({ println("  ✅ 简化流程: 管理层特权") })
            .build()
    )

    // 测试场景
    println("📊 审批场景:")
    println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

    let requests = [
        ("REQ-001", "采购申请", 300.0, "普通员工", "技术部", "普通", 3, "小额自动批准"),
        ("REQ-002", "采购申请", 8000.0, "普通员工", "市场部", "普通", 5, "中等金额双重审批"),
        ("REQ-003", "差旅申请", 25000.0, "主管", "销售部", "普通", 2, "大额多级审批"),
        ("REQ-004", "采购申请", 150000.0, "部门经理", "运营部", "普通", 8, "超大额CEO审批"),
        ("REQ-005", "项目立项", 50000.0, "总监", "研发部", "紧急", 4, "紧急大额"),
        ("REQ-006", "费用报销", 200.0, "普通员工", "人事部", "普通", 0, "缺少附件"),
        ("REQ-007", "团建申请", 5000.0, "管理层", "技术部", "普通", 2, "管理层简化"),
    ]

    var results = ArrayList<ApprovalResult>()

    for (request in requests) {
        let (id, type, amount, level, dept, urgency, attachments, desc) = request
        println("\n🔍 场景: ${desc}")

        engine.reset()
        engine.insert(ApprovalRequest(id, type, amount, level, dept, urgency, attachments))

        let result = ApprovalResult(id, type, amount)

        // 分析审批流程
        if (attachments == 0) {
            result.setRejected("缺少必要附件")
        } else if (amount <= 500.0 && type == "采购申请") {
            result.setAutoApproved("小额采购自动批准规则")
        } else if (level == "管理层" && amount <= 10000.0) {
            result.setAutoApproved("管理层简化流程")
        } else if (amount >= 100000.0) {
            result.addApprover("部门经理审批")
            result.addApprover("财务总监审批")
            result.addApprover("副总裁审批")
            result.addApprover("CEO审批")
        } else if (amount > 20000.0) {
            result.addApprover("部门经理审批")
            result.addApprover("财务总监审批")
            result.addApprover("副总裁审批")
        } else if (amount > 5000.0) {
            result.addApprover("部门经理审批")
            result.addApprover("财务审批")
        } else if (level == "普通员工") {
            result.addApprover("部门主管审批")
        }

        if (urgency == "紧急" && !result.autoApproved && result.rejectReason == "") {
            result.approvalPath.insert(0, "⚡ 紧急快速通道")
        }

        results.add(result)
        println(result.toString())

        engine.fireAllRules()
    }

    // 统计报告
    println("\n📈 审批统计:")
    println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

    var autoApproved = 0
    var rejected = 0
    var manual = 0

    for (result in results) {
        if (result.autoApproved) {
            autoApproved++
        } else if (result.rejectReason != "") {
            rejected++
        } else {
            manual++
        }
    }

    println("  自动批准: ${autoApproved}")
    println("  需要审批: ${manual}")
    println("  拒绝: ${rejected}")
    println("  自动化率: ${(autoApproved * 100 / results.size)}%")

    println("\n💡 审批流程特点:")
    println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    println("✅ 智能路由 - 根据金额和类型自动分配审批流程")
    println("✅ 快速通道 - 紧急申请优先处理")
    println("✅ 风险控制 - 大额金额多级审批")
    println("✅ 效率提升 - 小额申请自动批准")
    println("✅ 合规检查 - 缺少附件自动拒绝")
    println("✅ 权限管理 - 管理层简化流程")
    println("")
}
