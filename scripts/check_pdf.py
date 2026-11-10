#!/usr/bin/env python3
"""对编译后的 PDF 做结构、版面和字体检查。

用法：
    python3 scripts/check_pdf.py build/qznu-thesis.pdf
    python3 scripts/check_pdf.py build/qznu-thesis.pdf --log build/qznu-thesis.log
"""

from __future__ import annotations

import argparse
import re
import subprocess
import sys
from pathlib import Path


def run(*args: str) -> str:
    return subprocess.check_output(args, text=True, stderr=subprocess.STDOUT)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("pdf", type=Path)
    parser.add_argument("--log", type=Path, default=None)
    args = parser.parse_args()

    if not args.pdf.exists():
        print(f"[FAIL] 找不到 PDF：{args.pdf}")
        return 1

    info = run("pdfinfo", str(args.pdf))
    text = run("pdftotext", "-layout", str(args.pdf), "-")
    fonts = run("pdffonts", str(args.pdf))

    checks: list[tuple[str, bool, str]] = []

    pages_match = re.search(r"^Pages:\s+(\d+)", info, re.M)
    pages = int(pages_match.group(1)) if pages_match else 0
    checks.append(("页数不少于 12 页", pages >= 12, f"{pages} 页"))

    size_match = re.search(r"^Page size:\s+([\d.]+) x ([\d.]+)", info, re.M)
    if size_match:
        width, height = float(size_match.group(1)), float(size_match.group(2))
        a4 = abs(width - 595.276) < 2 and abs(height - 841.89) < 2
    else:
        a4 = False
    checks.append(("A4 页面尺寸", a4, size_match.group(0) if size_match else "无法读取"))

    required = {
        "中文题目": "泉州世遗文化融入初中语文综合性学习研究",
        "中文摘要标记": r"摘\s*要",
        "英文摘要": "Abstract",
        "英文关键词": "Keywords",
        "目录": r"目\s*录",
        "绪论": "绪论",
        "结论": "结论",
        "参考文献": "参考文献",
        "致谢": "致谢",
        "附录 A": r"附录\s*A",
        "附录 B": r"附录\s*B",
        "图 3-1": r"图\s*3-1",
        "表 3-1": r"表\s*3-1",
        "公式 (4-1)": r"[（(]\s*4-1\s*[）)]",
    }
    for label, pattern in required.items():
        ok = bool(re.search(pattern, text))
        checks.append((f"包含{label}", ok, "找到" if ok else "缺失"))

    cjk_fonts = []
    for line in fonts.splitlines()[2:]:
        if not line.strip():
            continue
        cols = line.split()
        if len(cols) >= 5 and re.search(r"(Songti|Fandol|SimSun|Song|Heiti|Kai|STSong|STHeiti)", line):
            emb = next((c for c in cols[3:] if c in {"yes", "no"}), "")
            cjk_fonts.append((cols[0], emb))
    font_ok = bool(cjk_fonts) and all(emb == "yes" for _, emb in cjk_fonts)
    detail = f"{len(cjk_fonts)} 个中文字体" if cjk_fonts else "未检测到中文字体"
    checks.append(("中文字体已嵌入", font_ok, detail))

    if args.log and args.log.exists():
        log = args.log.read_text(encoding="utf-8", errors="replace")
        checks.append(("日志无致命错误", not re.search(r"(?m)^!", log), "无“!”错误"))
        checks.append(("无未定义引用", not re.search(r"(Citation|Reference).*undefined", log), "无未定义引用"))
        missing = re.findall(r"Missing character: There is no (.+?) in font", log)
        checks.append(("日志无缺失字符", not missing,
                       "无" if not missing else "缺失：" + "、".join(missing[:5])))
        overfull = [float(x) for x in re.findall(r"Overfull \\hbox \(([\d.]+)pt too wide\)", log)]
        checks.append(("无超过 5pt 的 Overfull hbox", all(x <= 5 for x in overfull),
                       f"最大 {max(overfull):.2f}pt" if overfull else "无"))
        geometry = re.search(
            r"QZNU-GEOMETRY: textwidth=([\d.]+)pt, textheight=([\d.]+)pt", log)
        if geometry:
            tw, th = float(geometry.group(1)), float(geometry.group(2))
            checks.append(("版心宽度 16.5 cm", abs(tw - 469.47) < 1, f"{tw:.2f}pt"))
            checks.append(("版心高度 25.7 cm", abs(th - 731.24) < 1, f"{th:.2f}pt"))

    width = max(len(name) for name, _, _ in checks)
    failed = 0
    print("PDF 检查")
    print("-" * (width + 24))
    for name, ok, detail in checks:
        status = "PASS" if ok else "FAIL"
        if not ok:
            failed += 1
        print(f"[{status}] {name:<{width}}  {detail}")
    print("-" * (width + 24))
    print(f"文件：{args.pdf}")
    if failed:
        print(f"结果：{failed} 项未通过。")
        return 1
    print("结果：全部通过。")
    return 0


if __name__ == "__main__":
    sys.exit(main())
