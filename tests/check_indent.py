#!/usr/bin/env python3
"""检查标题后的第一段是否与后续段落一样有首行缩进。"""
from __future__ import annotations

import re
import subprocess
import sys
from pathlib import Path


def main() -> int:
    if len(sys.argv) != 2:
        print("用法: check_indent.py <pdf>")
        return 2
    pdf = Path(sys.argv[1])
    bbox = subprocess.check_output(["pdftotext", "-bbox-layout", str(pdf), "-"], text=True)
    rows = re.findall(r'<line\b[^>]*xMin="([\d.]+)"[^>]*>(.*?)</line>', bbox, re.S)
    checks = []
    for label in ("第一段", "第二段"):
        xs = [float(x) for x, body in rows if label in body]
        ok = bool(xs) and all(x > 80 for x in xs)
        checks.append((label, ok, xs))
    failed = 0
    for label, ok, xs in checks:
        print(f"[{'PASS' if ok else 'FAIL'}] {label}首行缩进  xMin={xs}")
        if not ok:
            failed += 1
    if failed:
        print("标题后首段缩进检查未通过。")
        return 1
    print("标题后首段缩进检查通过。")
    return 0


if __name__ == "__main__":
    sys.exit(main())
