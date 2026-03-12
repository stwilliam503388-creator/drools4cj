# Drools4Cj - 安装指南

## 📋 环境要求

### 必需环境

- **操作系统**: macOS 11+ / Linux (Ubuntu 20.04+)
- **仓颉编译器**: cjc 1.0.0 或更高版本
- **仓颉包管理器**: cjpm 1.0.0 或更高版本 (推荐)
- **内存**: 至少 2GB RAM
- **磁盘空间**: 至少 100MB 可用空间

### 可选环境

- **IDE**: VS Code + 仓颉插件 / IntelliJ IDEA + 仓颉插件
- **Git**: 用于克隆项目

---

## 🔧 安装步骤

### 1. 安装仓颉工具链

#### macOS

```bash
# 下载仓颉工具链
curl -L https://cangjie-lang.cn/download -o cangjie-toolchain.tar.gz

# 解压安装
tar -xzf cangjie-toolchain.tar.gz

# 添加到 PATH (在 ~/.zshrc 或 ~/.bashrc 中)
export PATH=$PATH:/path/to/cangjie/bin

# 验证安装
cjc --version   # cjc version 1.0.0
cjpm --version  # cjpm version 1.0.0
```

#### Linux

```bash
# 下载仓颉工具链
wget https://cangjie-lang.cn/packages/cjc-linux-x64.tar.gz

# 解压
tar -xzf cjc-linux-x64.tar.gz

# 添加到 PATH
export PATH=$PATH:/path/to/cjc/bin

# 验证安装
cjc --version
cjpm --version
```

### 2. 克隆项目

```bash
# HTTPS 方式
git clone https://github.com/yourusername/drools4cj.git

# 或 SSH 方式 (需配置 GitHub SSH 密钥)
git clone git@github.com:yourusername/drools4cj.git

# 进入项目目录
cd drools4cj
```

### 3. 编译项目

#### 方式一：使用 cjpm (推荐)

```bash
# 使用仓颉包管理器构建
cjpm build

# 运行测试
cjpm test
```

#### 方式二：直接编译

```bash
# 编译核心模块 (src/ 目录)
cd src
cjc -c *.cj
cd ..

# 编译示例
cjc examples/DiscountExample.cj -o discount_example

# 编译测试(如果需要)
cjc -c src/*.cj tests/unit/FactTest.cj
```

### 4. 运行示例

```bash
# 运行折扣规则示例
./examples/discount_example
```

**预期输出:**
```
╔══════════════════════════════════════════════════════╗
║     Drools4Cj - 订单折扣规则示例                      ║
╚══════════════════════════════════════════════════════╝

📝 定义业务规则:
  ── 订单金额 > 1000 → 9折
  ── 商品数 > 10 → 8.5折
  ── VIP 客户 → 额外95折

📦 插入订单事实:
  订单1: 普通客户,金额 1200 元,5 件商品
  订单2: VIP 客户,金额 800 元,15 件商品
  ...

🔥 执行规则...
  ✨ 规则触发: 订单金额超过 1000,享受 9 折优惠!
  👑 规则触发: VIP 客户,额外享受 95 折优惠!
  ...

✅ 示例完成
```

---

## 🏗️ 项目结构

### 标准项目结构

```
drools4cj/
├── core/                      # 核心实现
│   ├── Fact.cj               # 事实对象基类
│   ├── Rule.cj               # 规则定义
│   ├── WorkingMemory.cj      # 工作内存
│   ├── MatcherAndAgenda.cj   # 模式匹配和议程
│   └── RuleEngine.cj         # 规则引擎
│
├── tests/                     # 测试工程
│   ├── unit/                 # 单元测试
│   ├── integration/          # 集成测试
│   ├── performance/         # 性能测试
│   └── run_all_tests.sh     # 自动化测试脚本
│
├── examples/                  # 示例代码
│   ├── DiscountExample.cj    # 折扣规则
│   ├── RiskControlExample.cj # 风控规则
│   └── DynamicPricing.cj     # 动态定价
│
├── docs/                      # 文档
│   ├── API.md                # API 完整参考
│   ├── ARCHITECTURE.md       # 架构设计
│   ├── PERFORMANCE.md       # 性能详解
│   └── TESTING.md           # 测试说明
│
├── README.md                  # 项目说明
├── LICENSE                    # MIT 许可证
├── INSTALL.md                 # 安装指南(本文件)
└── CONTRIBUTING.md            # 贡献指南
```

---

## 🔍 验证安装

### 检查编译器

```bash
cjc --version
```

**预期输出:**
```
cjc version 1.0.0
Cangjie Compiler
Copyright (c) 2023-2025 Huawei
```

### 运行测试

```bash
./tests/run_all_tests.sh
```

**预期输出:**
```
✅ PASS: FactTest - OrderFact 创建
✅ PASS: FactTest - 金额条件匹配
...
✅ 所有测试通过!
```

### 运行示例

```bash
./examples/discount_example
```

---

## ⚙️ 配置选项

### 编译选项

```bash
# 标准编译
cjc example.cj -o example

# 优化编译
cjc -O example.cj -o example

# 调试编译
cjc -g example.cj -o example_debug
```

### 环境变量

```bash
# 设置仓颉工具链路径
export CANGJIE_HOME=/path/to/cangjie
export PATH=$PATH:$CANGJIE_HOME/bin
```

---

## 🐛 常见问题

### Q1: 编译错误 "找不到 cjc"

**问题:**
```bash
cjc: command not found
```

**解决方案:**
1. 确认已安装仓颉编译器: `which cjc`
2. 如果未安装,按照上述安装步骤安装
3. 添加到 PATH: `export PATH=$PATH:/path/to/cjc/bin`

### Q2: 编译失败 "找不到类型"

**问题:**
```
error: cannot find type Rule
```

**解决方案:**
1. 确保所有核心文件在同一目录
2. 同时编译所有文件: `cjc -c *.cj`
3. 检查 import 路径是否正确

### Q3: 运行时错误 "找不到动态库"

**问题:**
```
error: cannot load dynamic library
```

**解决方案:**
1. 检查仓颉运行时是否安装
2. 设置 LD_LIBRARY_PATH:
   ```bash
   export LD_LIBRARY_PATH=$CANGJIE_HOME/lib:$LD_LIBRARY_PATH
   ```

### Q4: 性能问题

**问题:**
运行速度比预期慢

**解决方案:**
1. 启用优化编译: `cjc -O`
2. 减少日志输出
3. 使用批量插入而非逐个插入

---

## 📚 学习资源

### 官方文档

- [仓颉编程语言官网](https://cangjie-lang.cn/)
- [仓颉标准库文档](https://cangjie-lang.cn/std/)
- [仓颉语法指南](https://cangjie-lang.cn/docs/syntax/)

### 教程

- [仓颉快速入门](https://cangjie-lang.cn/docs/quickstart/)
- [仓颉最佳实践](https://cangjie-lang.cn/docs/bestpractices/)
- [Drools4Cj 示例](https://github.com/yourusername/drools4cj/tree/main/examples)

### 社区

- [仓颉官方论坛](https://cangjie-lang.cn/forum/)
- [GitHub Discussions](https://github.com/yourusername/drools4cj/discussions)

---

## 🆘 获取帮助

如果遇到问题:

1. 查看 [FAQ](docs/FAQ.md)
2. 搜索 [Issues](https://github.com/yourusername/drools4cj/issues)
3. 提交 [新 Issue](https://github.com/yourusername/drools4cj/issues/new)

---

**下一步:** 查看 [API 文档](docs/API.md) 开始使用!
