# 贡献指南

感谢你对 Drools4Cj 项目的关注!我们欢迎各种形式的贡献。

---

## 🎯 贡献类型

### 代码贡献

- 🐛 Bug 修复
- ✨ 新功能开发
- ♻️ 代码重构
- 📝 文档改进
- 🧪 测试增强

### 非代码贡献

- 📖 文档翻译
- 💡 建议 and 反馈
- 🐛 问题报告
- 📢 项目推广

---

## 🚀 快速开始

### 1. 准备工作

#### Fork 项目

```bash
# 点击 GitHub 页面右上角的 Fork 按钮
git clone https://github.com/yourusername/drools4cj.git
cd drools4cj
```

#### 配置开发环境

```bash
# 安装仓颉编译器
brew install cjc  # macOS
# 或
wget https://cangjie-lang.cn/packages/cjc-linux-x64.tar.gz  # Linux

# 验证安装
cjc --version
```

#### 创建功能分支

```bash
git checkout -b feature/your-feature-name
```

### 2. 开发流程

#### 编写代码

1. 遵循现有代码风格
2. 添加必要的注释
3. 编写单元测试
4. 更新相关文档

#### 测试

```bash
# 运行所有测试
./tests/run_all_tests.sh

# 确保所有测试通过
```

#### 提交更改

```bash
git add .
git commit -m "Add: 简洁的提交信息"
```

### 3. Pull Request

#### 推送到分支

```bash
git push origin feature/your-feature-name
```

#### 创建 Pull Request

1. 访问 GitHub 项目页面
2. 点击 "Compare & pull request"
3. 选择你的分支
4. 填写 PR 描述

---

## 📋 开发规范

### 代码风格

#### 命名约定

```cangjie
// 类名: 大驼峰
public class WorkingMemory {}

// 函数名: 小驼峰
public func insertFact() {}

// 常量: 全大写下划线
public const MAX_SIZE = 10000

// 私有变量: 小驼峰
private var factCount = 0
```

#### 文件组织

```cangjie
// 1. License header
/*
 * Drools4Cj - [模块说明]
 */

// 2. Package 声明
package core

// 3. Import
import std.collection.*

// 4. 类/函数定义
public class Example {
    // ...
}
```

#### 注释规范

```cangjie
/**
 * 函数/类的简要说明
 *
 * 详细描述...
 *
 * @param paramName 参数说明
 * @return 返回值说明
 */
```

### 测试规范

#### 单元测试

```cangjie
class FactTest {
    public func testXX() {
        // Arrange
        let fact = OrderFact("ORDER-001", "VIP", 1000.0, 5)

        // Act
        let condition = Condition("amount", ">", PropertyValue(500.0))

        // Assert
        assert(fact.matches(condition), "应该匹配条件")
    }
}
```

#### 测试覆盖率

- 核心模块: 100%
- 工具模块: >90%
- 示例代码: >80%

---

## 📝 Pull Request 模板

### PR 标题

```
[类型] 简短描述

类型: feat / fix / docs / refactor / test / chore
```

### PR 描述

```markdown
## 变更内容

简要描述本次变更的内容...

## 变更原因

说明为什么需要这个变更...

## 测试

- [ ] 单元测试已添加/更新
- [ ] 所有测试通过
- [ ] 手动测试通过

## 文档

- [ ] API 文档已更新
- [ ] README 已更新
- [ ] 示例代码已更新

## 截图/演示

(如果适用)添加截图或演示...
```

### 检查清单

- [ ] 遵循代码规范
- [ ] 添加了测试
- [ ] 更新了文档
- [ ] 通过所有测试
- [ ] 冲突已解决

---

## 🔍 审查流程

### 自动检查

所有 PR 会自动运行以下检查:

- ✅ 编译检查
- ✅ 单元测试
- ✅ 代码风格检查
- ✅ 文档完整性

### 人工审查

项目维护者会审查以下内容:

1. **代码质量**
   - 代码清晰易读
   - 遵循项目规范
   - 无明显性能问题

2. **功能完整性**
   - 功能实现完整
   - 边界情况处理
   - 错误处理完善

3. **测试覆盖**
   - 单元测试充分
   - 测试覆盖率达标
   - 测试用例合理

4. **文档完整**
   - API 文档更新
   - 示例代码清晰
   - README 更新

---

## 🐛 Bug 报告

### 报告 Bug

使用 GitHub Issues 报告 Bug,请包含:

1. **标题** - 清晰描述 Bug
2. **环境信息**
   - OS 和版本
   - 仓颉编译器版本
   - 项目版本

3. **重现步骤**
   - 详细的操作步骤
   - 预期行为
   - 实际行为

4. **最小复现示例**
   - 简化的代码示例
   - 相关数据

5. **日志/错误信息**
   - 完整的错误堆栈
   - 相关日志输出

### Bug 报告模板

```markdown
### Bug 描述
简要描述 Bug...

### 复现步骤
1. 步骤 1
2. 步骤 2
3. ...

### 预期行为
应该发生...

### 实际行为
实际发生了...

### 环境信息
- OS: macOS 14.0
- cjc: 1.0.0
- Drools4Cj: v1.0.0

### 附加信息
日志、截图等...
```

---

## 💡 功能建议

### 建议新功能

使用 GitHub Discussions 讨论新功能想法,请包含:

1. 功能描述和使用场景
2. 与现有功能的关系
3. 实现建议(如果有的话)
4. 对项目的影响

---

## 📚 开发资源

### 技术文档

- [仓颉编程语言](https://cangjie-lang.cn/)
- [仓颉标准库](https://cangjie-lang.cn/std/)
- [Drools 文档](https://docs.drools.org/)

### 项目文档

- [API 文档](docs/API.md)
- [架构设计](docs/ARCHITECTURE.md)
- [性能文档](docs/PERFORMANCE.md)

### 仓颉 Skills

在本项目中使用的仓颉 Skills:

- `/cj-basic-types` - 查询基本类型
- `/cj-collections` - 查询集合类型

---

## 🤝 社区规范

### 行为准则

1. **尊重他人** - 友善、专业
2. **建设性反馈** - 提供建设性意见
3. **开放心态** - 接受不同观点
4. **协作共赢** - 以项目利益为先

### 沟通渠道

- **讨论**: [GitHub Discussions](https://github.com/yourusername/drools4cj/discussions)
- **问题**: [GitHub Issues](https://github.com/yourusername/drools4cj/issues)
- **安全**: security@example.com

---

## ⭐ 成为贡献者

所有贡献者将在项目中获得致谢:

- [ CONTRIBUTORS.md](CONTRIBUTORS.md) - 贡献者列表
- README 中感谢主要贡献者
- Release Notes 中列出贡献者

---

**感谢你的贡献!** 🎉
