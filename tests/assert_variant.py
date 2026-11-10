#!/usr/bin/env python3
"""检查四种章节编号方案的 PDF 是否出现对应标题。"""

from __future__ import annotations

import re
import subprocess
import sys
from pathlib import Path


def main() -> int:
    if len(sys.argv) != 3:
        print("用法: assert_variant.py <scheme 1-4> <pdf>")
        return 2
    scheme, pdf = sys.argv[1], Path(sys.argv[2])
    text = subprocess.check_output(["pdftotext", "-layout", str(pdf), "-"], text=True)

    if scheme == "1":
        heading = r"(?m)^\s*1\s+绪论"
        toc = r"(?m)^\s*1\s+绪论\s*\."
    elif scheme == "2":
        heading = r"(?m)^\s*一、\s*绪论"
        toc = r"(?m)^\s*一、\s*绪论\s*\."
    else:
        heading = r"(?m)^\s*第\s*一\s*章\s*绪论"
        toc = r"(?m)^\s*第\s*一\s*章\s*绪论\s*\."

    checks = [
        (f"scheme {scheme} 正文一级标题", bool(re.search(heading, text))),
        (f"scheme {scheme} 目录一级标题", bool(re.search(toc, text))),
        ("图 3-1", bool(re.search(r"图\s*3-1", text))),
        ("表 3-1", bool(re.search(r"表\s*3-1", text))),
        ("公式 (4-1)", bool(re.search(r"[（(]\s*4-1\s*[）)]", text))),
        ("附录 B 表 B-1", bool(re.search(r"表\s*B-1", text))),
        ("无未定义引用标记", "??" not in text),
    ]
    failed = 0
    for name, ok in checks:
        print(f"[{'PASS' if ok else 'FAIL'}] {name}")
        if not ok:
            failed += 1
    if failed:
        print(f"scheme {scheme}：{failed} 项未通过")
        return 1
    print(f"scheme {scheme}：全部通过")
    return 0


if __name__ == "__main__":
    sys.exit(main())
