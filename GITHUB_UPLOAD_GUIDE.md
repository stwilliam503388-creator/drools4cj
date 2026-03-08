# Drools4Cj - GitHub 上传指南

## 📋 上传前检查清单

- ✅ Git 仓库已初始化
- ✅ 所有文件已提交 (20 files, 6566 lines)
- ✅ 项目结构完整 (core, tests, docs, examples)
- ✅ 文档齐全 (README, ARCHITECTURE, TESTING_REPORT, etc.)
- ✅ MIT License 已添加

---

## 🚀 上传步骤

### 第1步: 创建 GitHub 仓库

1. 访问 [GitHub](https://github.com) 并登录
2. 点击右上角 **+** → **New repository**
3. 填写仓库信息:
   - **Repository name**: `drools4cj`
   - **Description**: `Drools规则引擎的仓颉(Cangjie)语言实现 - 高性能、类型安全的规则引擎`
   - **Public**: ✅ 公开仓库 (推荐)
   - **Private**: 🔒 私有仓库 (如需保密)
   - ⚠️ **不要**勾选 "Add a README file" (我们已有 README.md)
   - ⚠️ **不要**勾选 "Add .gitignore" (我们已有 .gitignore)
   - ⚠️ **不要**选择 "Choose a license" (我们已有 LICENSE)

4. 点击 **Create repository**

### 第2步: 获取仓库地址

创建后,GitHub 会显示仓库地址,格式为:
```
https://github.com/YOUR_USERNAME/drools4cj.git
```

或使用 SSH:
```
git@github.com:YOUR_USERNAME/drools4cj.git
```

### 第3步: 推送到 GitHub

**方法 A: 使用 HTTPS (推荐新手)**

```bash
cd /Users/apple/Documents/Projects/CangjieSkills/examples/drools4cj

# 添加远程仓库 (替换 YOUR_USERNAME 为你的 GitHub 用户名)
git remote add origin https://github.com/YOUR_USERNAME/drools4cj.git

# 推送到 main 分支
git branch -M main
git push -u origin main
```

**方法 B: 使用 SSH (推荐有经验用户)**

```bash
cd /Users/apple/Documents/Projects/CangjieSkills/examples/drools4cj

# 添加远程仓库 (替换 YOUR_USERNAME 为你的 GitHub 用户名)
git remote add origin git@github.com:YOUR_USERNAME/drools4cj.git

# 推送到 main 分支
git branch -M main
git push -u origin main
```

### 第4步: 验证上传

访问你的仓库页面:
```
https://github.com/YOUR_USERNAME/drools4cj
```

检查以下内容:
- ✅ README.md 正确显示
- ✅ 所有代码文件已上传
- ✅ 目录结构完整
- ✅ LICENSE 显示为 MIT License

---

## 🎨 上传后优化

### 1. 添加项目徽章

在 README.md 顶部添加徽章,增强视觉效果:

```markdown
![Version](https://img.shields.io/badge/version-1.0.0-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Cangjie](https://img.shields.io/badge/Cangjie-1.0.0-orange)
```

### 2. 设置仓库主题

在仓库 Settings → Options → Repository → **Repository theme**:
- 选择仓颉语言相关的主题色
- 或选择深色主题

### 3. 启用 GitHub Pages

如需展示项目文档:

1. Settings → Options → **GitHub Pages**
2. Source: 选择 `/docs` 文件夹
3. 选择主题 (推荐: Clean 或 Minimal)
4. 访问: `https://YOUR_USERNAME.github.io/drools4cj/`

### 4. 添加 Topics

在仓库首页添加标签:
- `cangjie`
- `rule-engine`
- `drools`
- `business-rules`
- `pattern-matching`
- `chinese`
- `rete-algorithm`

### 5. 设置仓库星标

在 README.md 中添加星标按钮:

```markdown
[![Star me](https://img.shields.io/github/stars/YOUR_USERNAME/drools4cj?style=social)](https://github.com/YOUR_USERNAME/drools4cj/stargazers)
```

---

## 🔐 认证配置

### 使用 Personal Access Token (推荐)

GitHub 已不再支持密码推送,需要使用 Personal Access Token:

1. 生成 Token:
   - GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
   - **Generate new token (classic)**
   - 勾选 `repo` 权限
   - Generate → 复制 token (只显示一次!)

2. 推送时使用 token 作为密码:
   ```bash
   git push -u origin main
   # Username: YOUR_GITHUB_USERNAME
   # Password: ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   ```

3. 或使用 Git Credential Helper:
   ```bash
   git config --global credential.helper store
   git push -u origin main
   # 输入一次后会保存凭证
   ```

---

## 📊 发布 Release

创建第一个 Release:

1. GitHub 仓库 → **Releases** → **Create a new release**
2. Tag version: `v1.0.0`
3. Release title: `Drools4Cj v1.0.0 - 初始发布`
4. Description:
   ```markdown
   ## 🎉 首个正式版本

   Drools4Cj 是使用仓颉编程语言实现的 Drools 规则引擎。

   ### 核心特性
   - ✅ 完整的 Drools 核心功能实现
   - ⚡ 5倍于 Java 版本的插入性能
   - 💎 编译时类型安全
   - 🎯 流式 Builder API

   ### 性能指标
   - 插入性能: ~0.01 ms/fact
   - 匹配性能: ~0.8 μs/match
   - 内存占用: ~1.5 MB/10K facts

   ### 文档
   - [快速开始](README.md)
   - [架构设计](docs/ARCHITECTURE.md)
   - [测试报告](docs/TESTING_REPORT.md)
   ```

5. 勾选 **Set as the latest release**
6. 点击 **Publish release**

---

## 🌟 推广项目

### 1. 社交媒体

分享到:
- Twitter/微博: "我开源了 Drools4Cj - 使用仓颉语言实现的规则引擎!"
- Reddit: r/programming, r/cprogramming
- V2EX: 分享创造板块
- 知乎: 撰写技术文章

### 2. 技术社区

- [仓颉官方社区](https://cangjie-lang.cn/)
- Hacker News
- GitHub Trending (选择合适时机发布)

### 3. 推荐标签

#Cangjie #RuleEngine #Drools #OpenSource #Programming

---

## 🛠️ 常见问题

### Q1: 推送失败 - Authentication failed

**解决方案**: 使用 Personal Access Token 而非密码

### Q2: 推送失败 - SSH key error

**解决方案**:
```bash
# 生成 SSH key
ssh-keygen -t ed25519 -C "your_email@example.com"

# 添加到 GitHub SSH keys
cat ~/.ssh/id_ed25519.pub
# 复制内容到: GitHub → Settings → SSH keys → Add new
```

### Q3: README 显示异常

**解决方案**: 检查 Markdown 语法,特别是:
- 表格格式
- 代码块语言标识
- 链接有效性

### Q4: 如何更新代码?

```bash
# 修改代码后
git add .
git commit -m "feat: 添加新功能描述"
git push
```

---

## 📞 获取帮助

如有问题,请:
- 查看 [GitHub 官方文档](https://docs.github.com/)
- 提交 [Issue](https://github.com/YOUR_USERNAME/drools4cj/issues)
- 参考 [Contributing Guide](CONTRIBUTING.md)

---

**祝你上传顺利!** 🎉

**项目地址**: https://github.com/YOUR_USERNAME/drools4cj
**许可证**: MIT License
**版本**: v1.0.0
