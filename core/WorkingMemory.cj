/*
 * Drools 规则引擎 - 仓颉实现
 * 文件: WorkingMemory.cj
 * 说明: 工作内存实现
 */

package core

import std.collection.HashMap
import std.collection.ArrayList
import std.collection.HashSet

// ==================== 工作内存 ====================

/**
 * 工作内存
 * 负责存储和管理所有事实对象
 */
public class WorkingMemory {
    // 主存储: ID -> Fact
    private var facts: HashMap<String, Fact> = HashMap()

    // 类型索引: Type -> ArrayList<Fact>
    private var typeIndex: HashMap<String, ArrayList<Fact>> = HashMap()

    // 事实版本控制(用于更新检测)
    private var versions: HashMap<String, Int64> = HashMap()

    private var versionCounter: Int64 = 0

    public init() {}

    /**
     * 插入事实
     */
    public func insert(fact: Fact): Int64 {
        let version = ++versionCounter

        facts[fact.id] = fact
        versions[fact.id] = version

        // 更新类型索引
        if (!typeIndex.contains(fact.type)) {
            typeIndex[fact.type] = ArrayList<Fact>()
        }
        typeIndex[fact.type]?.append(fact)

        println("[WorkingMemory] ➕ 插入事实: ${fact.type}:${fact.id} (v${version})")

        return version
    }

    /**
     * 更新事实
     */
    public func update(fact: Fact): Bool {
        if (!facts.contains(fact.id)) {
            println("[WorkingMemory] ⚠️ 事实不存在,无法更新: ${fact.id}")
            return false
        }

        let version = ++versionCounter
        facts[fact.id] = fact
        versions[fact.id] = version

        println("[WorkingMemory] 🔄 更新事实: ${fact.type}:${fact.id} (v${version})")

        return true
    }

    /**
     * 撤回事实
     */
    public func retract(factId: String): Bool {
        if (!facts.contains(factId)) {
            println("[WorkingMemory] ⚠️ 事实不存在,无法撤回: ${factId}")
            return false
        }

        let fact = facts[factId]
        let factType = fact.type

        facts.remove(factId)
        versions.remove(factId)

        // 从类型索引中移除
        if (let factList = typeIndex[factType]) {
            factList.removeAll({ f => f.id == factId })

            // 如果该类型没有事实了,删除索引
            if (factList.isEmpty) {
                typeIndex.remove(factType)
            }
        }

        println("[WorkingMemory] ➖ 撤回事实: ${factType}:${factId}")

        return true
    }

    /**
     * 根据ID获取事实
     */
    public func getFact(id: String): Option<Fact> {
        if (!facts.contains(id)) {
            return None
        }
        return Some(facts[id])
    }

    /**
     * 根据类型获取所有事实
     */
    public func getFactsByType(type: String): ArrayList<Fact> {
        return typeIndex.get(type, ArrayList<Fact>())
    }

    /**
     * 获取所有事实
     */
    public func getAllFacts(): ArrayList<Fact> {
        var result = ArrayList<Fact>()
        for ((_, fact) in facts) {
            result.add(fact)
        }
        return result
    }

    /**
     * 获取事实版本
     */
    public func getVersion(factId: String): Option<Int64> {
        if (!versions.contains(factId)) {
            return None
        }
        return Some(versions[factId])
    }

    /**
     * 检查事实是否存在
     */
    public func contains(factId: String): Bool {
        return facts.contains(factId)
    }

    /**
     * 获取事实总数
     */
    public func getSize(): Int64 {
        return facts.size
    }

    /**
     * 按类型统计
     */
    public func getTypeStats(): HashMap<String, Int64> {
        var stats = HashMap<String, Int64>()
        for ((type, factList) in typeIndex) {
            stats[type] = factList.size
        }
        return stats
    }

    /**
     * 清空工作内存
     */
    public func clear() {
        let factCount = facts.size
        let typeCount = typeIndex.size

        facts.clear()
        typeIndex.clear()
        versions.clear()
        versionCounter = 0

        println("[WorkingMemory] 🗑️ 清空工作内存: 清理 ${factCount} 个事实, ${typeCount} 个类型")
    }

    /**
     * 获取统计信息
     */
    public func getStats(): String {
        return "事实总数: ${facts.size}, 类型数: ${typeIndex.size}"
    }

    /**
     * 打印所有事实
     */
    public func printFacts() {
        println("\n[WorkingMemory] 📋 当前事实列表:")
        println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        if (facts.isEmpty) {
            println("  (无事实)")
        } else {
            for ((_, fact) in facts) {
                println("  ${fact.toString()}")
            }
        }

        println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    }
}

// ==================== 事实事件 ====================

/**
 * 事实事件类型
 */
enum FactEvent {
    case Inserted(fact: Fact, version: Int64)
    case Updated(fact: Fact, oldVersion: Int64, newVersion: Int64)
    case Retracted(factId: String, factType: String)
}

/**
 * 事实事件监听器
 */
interface FactEventListener {
    func onEvent(event: FactEvent)
}

/**
 * 事实事件处理器
 */
public class FactEventProcessor {
    private var listeners: ArrayList<FactEventListener> = ArrayList()

    public init() {}

    public func addListener(listener: FactEventListener) {
        listeners.add(listener)
    }

    public func removeListener(listener: FactEventListener) {
        listeners.removeAll({ l => l === listener })
    }

    public func notify(event: FactEvent) {
        for (listener in listeners) {
            listener.onEvent(event)
        }
    }
}
