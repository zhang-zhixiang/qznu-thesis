#!/usr/bin/env bash
# 完整测试：主文档 + 四种章节编号 + 连续页码 + 左对齐标题。
# 需要 XeLaTeX、latexmk、BibTeX、poppler-utils (pdfinfo/pdftotext/pdffonts)。
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "============================================================"
echo "1/4 编译主文档（本机字体）"
echo "============================================================"
./scripts/build.sh

echo "============================================================"
echo "2/4 内容与 PDF 检查"
echo "============================================================"
python3 scripts/check_content.py
python3 scripts/check_pdf.py build/qznu-thesis.pdf --log build/qznu-thesis.log

echo "============================================================"
echo "3/4 四种章节编号方案（Fandol 字体，便于跨平台复现）"
echo "============================================================"
mkdir -p build/tests
for scheme in 1 2 3 4; do
  src="build/tests/scheme${scheme}.tex"
  sed "s/\\\\documentclass\\[[^]]*\\]{qznu-thesis}/\\\\documentclass[scheme=${scheme},fontset=fandol]{qznu-thesis}/" \
    qznu-thesis.tex > "$src"
  echo "--- scheme ${scheme} ---"
  latexmk -xelatex -interaction=nonstopmode -halt-on-error -file-line-error \
    -outdir=build/tests -jobname="scheme${scheme}" "$src" >/tmp/qznu-scheme${scheme}.log 2>&1
  python3 tests/assert_variant.py "$scheme" "build/tests/scheme${scheme}.pdf"
  if grep -Eq '(^!)|(Citation .* undefined)|(Reference .* undefined)' "build/tests/scheme${scheme}.log"; then
    echo "[FAIL] scheme ${scheme} 日志中存在错误或未定义引用"
    grep -E '(^!)|(Citation .* undefined)|(Reference .* undefined)' "build/tests/scheme${scheme}.log" | head
    exit 1
  fi
  echo "[PASS] scheme ${scheme} 日志无致命错误"
done

echo "============================================================"
echo "4/4 选项组合编译"
echo "============================================================"
for variant in continuous left; do
  src="build/tests/${variant}.tex"
  if [ "$variant" = "continuous" ]; then
    opts="scheme=1,fontset=fandol,pagenumber=continuous"
  else
    opts="scheme=1,fontset=fandol,chapteralign=left"
  fi
  sed "s/\\\\documentclass\\[[^]]*\\]{qznu-thesis}/\\\\documentclass[${opts}]{qznu-thesis}/" \
    qznu-thesis.tex > "$src"
  echo "--- ${variant} ---"
  latexmk -xelatex -interaction=nonstopmode -halt-on-error -file-line-error \
    -outdir=build/tests -jobname="$variant" "$src" >/tmp/qznu-${variant}.log 2>&1
  if grep -Eq '(^!)' "build/tests/${variant}.log"; then
    echo "[FAIL] ${variant} 编译失败"
    exit 1
  fi
  test -s "build/tests/${variant}.pdf"
  echo "[PASS] ${variant} 编译通过"
done

echo "============================================================"
echo "测试全部通过。主文件：build/qznu-thesis.pdf"
echo "============================================================"
