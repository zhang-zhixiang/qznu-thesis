#!/usr/bin/env bash
# 编译主文档。所有中间文件放入 build/，不污染源码目录。
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

mkdir -p build
latexmk \
  -xelatex \
  -interaction=nonstopmode \
  -halt-on-error \
  -file-line-error \
  -outdir=build \
  qznu-thesis.tex

printf '\n生成：%s\n' "$ROOT/build/qznu-thesis.pdf"
