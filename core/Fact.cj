/*
 * Drools 规则引擎 - 仓颉实现
 * 文件: Fact.cj
 * 说明: 事实对象基类和具体实现
 */

package core

// ==================== 基类定义 ====================

/**
 * 事实对象基类
 * 所有事实都必须继承此类
 */
public abstract class Fact {
    public var type: String
    public var id: String

    public init(type: String, id: String) {
        this.type = type
        this.id = id
    }

    /**
     * 检查事实是否匹配条件
     */
    public abstract func matches(condition: Condition): Bool

    /**
     * 返回事实的字符串表示
     */
    public abstract func toString(): String
}

// ==================== 具体事实类 ====================

/**
 * 订单事实
 * 用于订单折扣规则示例
 */
public class OrderFact : Fact {
    public var customer: String      // 客户类型: "普通", "VIP"
    public var amount: Float64      // 订单金额
    public var items: Int64         // 商品数量

    public init(id: String, customer: String, amount: Float64, items: Int64) {
        super("Order", id)
        this.customer = customer
        this.amount = amount
        this.items = items
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
            case "items" => {
                match (condition.operator) {
                    case ">" => return items > condition.value.asInt64()
                    case "<" => return items < condition.value.asInt64()
                    case ">=" => return items >= condition.value.asInt64()
                    case "<=" => return items <= condition.value.asInt64()
                    case "=" => return items == condition.value.asInt64()
                    case "!=" => return items != condition.value.asInt64()
                    case _ => return false
                }
            }
            case "customer" => {
                match (condition.operator) {
                    case "=" => return customer == condition.value.asString()
                    case "!=" => return customer != condition.value.asString()
                    case _ => return false
                }
            }
            case _ => {
                println("⚠️ 未知字段: ${condition.field}")
                return false
            }
        }
    }

    public override func toString(): String {
        return "Order[id=${id}, customer=${customer}, amount=${amount}, items=${items}]"
    }
}

/**
 * 产品事实
 * 用于定价规则示例
 */
public class ProductFact : Fact {
    public var name: String
    public var price: Float64
    public var stock: Int64

    public init(id: String, name: String, price: Float64, stock: Int64) {
        super("Product", id)
        this.name = name
        this.price = price
        this.stock = stock
    }

    public override func matches(condition: Condition): Bool {
        match (condition.field) {
            case "price" => {
                match (condition.operator) {
                    case ">" => return price > condition.value.asFloat64()
                    case "<" => return price < condition.value.asFloat64()
                    case ">=" => return price >= condition.value.asFloat64()
                    case "<=" => return price <= condition.value.asFloat64()
                    case "=" => return price == condition.value.asFloat64()
                    case _ => return false
                }
            }
            case "stock" => {
                match (condition.operator) {
                    case ">" => return stock > condition.value.asInt64()
                    case "<" => return stock < condition.value.asInt64()
                    case ">=" => return stock >= condition.value.asInt64()
                    case "<=" => return stock <= condition.value.asInt64()
                    case "=" => return stock == condition.value.asInt64()
                    case _ => return false
                }
            }
            case _ => return false
        }
    }

    public override func toString(): String {
        return "Product[id=${id}, name=${name}, price=${price}, stock=${stock}]"
    }
}

/**
 * 客户事实
 * 用于客户分级规则
 */
public class CustomerFact : Fact {
    public var name: String
    public var level: String        // 客户等级: "普通", "银卡", "金卡", "钻石"
    public var points: Int64        // 积分
    public var totalOrders: Int64   // 总订单数

    public init(id: String, name: String, level: String, points: Int64, totalOrders: Int64) {
        super("Customer", id)
        this.name = name
        this.level = level
        this.points = points
        this.totalOrders = totalOrders
    }

    public override func matches(condition: Condition): Bool {
        match (condition.field) {
            case "level" => {
                match (condition.operator) {
                    case "=" => return level == condition.value.asString()
                    case "!=" => return level != condition.value.asString()
                    case _ => return false
                }
            }
            case "points" => {
                match (condition.operator) {
                    case ">" => return points > condition.value.asInt64()
                    case "<" => return points < condition.value.asInt64()
                    case ">=" => return points >= condition.value.asInt64()
                    case "<=" => return points <= condition.value.asInt64()
                    case _ => return false
                }
            }
            case "totalOrders" => {
                match (condition.operator) {
                    case ">" => return totalOrders > condition.value.asInt64()
                    case "<" => return totalOrders < condition.value.asInt64()
                    case ">=" => return totalOrders >= condition.value.asInt64()
                    case "<=" => return totalOrders <= condition.value.asInt64()
                    case _ => return false
                }
            }
            case _ => return false
        }
    }

    public override func toString(): String {
        return "Customer[id=${id}, name=${name}, level=${level}, points=${points}, orders=${totalOrders}]"
    }
}
