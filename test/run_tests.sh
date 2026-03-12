#!/bin/bash
# Drools4Cj - 测试运行脚本 (符合 CangjieSkills 标准结构)
# 文件: test/run_tests.sh
# 说明: 运行所有测试 (LLT 低层测试 + HLT 高层测试)

echo "╔══════════════════════════════════════════════════════╗"
echo "║     Drools4Cj - 自动化测试套件 (CangjieSkills规范)  ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""

# 检查编译器
if ! command -v cjc &> /dev/null; then
    echo "❌ 错误: 未找到 cjc 编译器"
    echo "请先安装仓颉工具链: https://cangjie-lang.cn/download"
    exit 1
fi

echo "✅ 找到仓颉编译器: $(cjc --version 2>/dev/null || echo '未知版本')"
echo ""

# 创建临时目录
TMP_DIR="/tmp/drools4cj_tests"
rm -rf "$TMP_DIR"
mkdir -p "$TMP_DIR"

# 统计变量
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 运行测试函数
run_test() {
    local test_file="$1"
    local test_name="$2"
    TOTAL_TESTS=$((TOTAL_TESTS + 1))

    echo "▶️  运行: ${test_name}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    cjc "$test_file" -o "$TMP_DIR/test_${TOTAL_TESTS}" 2>&1 | head -20

    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ 编译失败: ${test_name}${NC}"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        echo ""
        return
    fi

    if [ -x "$TMP_DIR/test_${TOTAL_TESTS}" ]; then
        "$TMP_DIR/test_${TOTAL_TESTS}" > "$TMP_DIR/output_${TOTAL_TESTS}.txt" 2>&1
        local exit_code=$?

        if [ $exit_code -eq 0 ]; then
            echo -e "${GREEN}✅ 通过: ${test_name}${NC}"
            PASSED_TESTS=$((PASSED_TESTS + 1))
        else
            echo -e "${RED}❌ 失败: ${test_name}${NC}"
            FAILED_TESTS=$((FAILED_TESTS + 1))
        fi

        tail -20 "$TMP_DIR/output_${TOTAL_TESTS}.txt"
    else
        echo -e "${RED}❌ 可执行文件未生成${NC}"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi

    echo ""
}

# LLT - 低层单元测试
echo "📋 LLT 低层单元测试"
echo "════════════════════════════════════════════"
echo ""

run_test "test/LLT/FactTest.cj" "Fact 类单元测试"
run_test "test/LLT/WorkingMemoryTest.cj" "WorkingMemory 类单元测试"
run_test "test/LLT/RuleEngineTest.cj" "RuleEngine 类单元测试"

# HLT - 高层集成测试
echo "📋 HLT 高层集成测试"
echo "════════════════════════════════════════════"
echo ""

run_test "test/HLT/DiscountRulesIntegrationTest.cj" "折扣规则集成测试"
run_test "test/HLT/PerformanceTest.cj" "性能基准测试"

# 汇总
echo "╔══════════════════════════════════════════════════════╗"
echo "║              测试执行完成                             ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""
echo "📊 最终统计:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "总测试数: ${TOTAL_TESTS}"
echo -e "${GREEN}通过: ${PASSED_TESTS}${NC}"
echo -e "${RED}失败: ${FAILED_TESTS}${NC}"
if [ $TOTAL_TESTS -gt 0 ]; then
    echo "通过率: $(( PASSED_TESTS * 100 / TOTAL_TESTS ))%"
fi
echo ""

rm -rf "$TMP_DIR"

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}🎉 所有测试通过!${NC}"
    exit 0
else
    echo -e "${RED}⚠️  存在失败的测试!${NC}"
    exit 1
fi
