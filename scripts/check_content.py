#!/usr/bin/env python3
"""检查示例论文的内容性要求（不替代学院的人工审查）。

默认阈值依据泉州师范学院公开的本科毕业论文（设计）要求：
  - 中文题目一般不超过 20 字
  - 中文摘要 200--300 字
  - 关键词 3--5 个
  - 参考文献 10 篇以上
  - 正文（文科）8000 字以上；理工科等可用 --min-body 6000

用法：
    python3 scripts/check_content.py
    python3 scripts/check_content.py --min-body 6000
"""

from __future__ import annotations

import argparse
import glob
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

CJK_RE = re.compile(r"[\u4e00-\u9fff]")


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def command_value(text: str, command: str) -> str:
    """读取 TeX 命令的单层参数。"""
    match = re.search(r"\\" + re.escape(command) + r"\{(.*?)\}", text, re.S)
    return match.group(1).strip() if match else ""


def strip_latex(text: str) -> str:
    text = re.sub(r"(?<!\\)%.*", "", text)
    text = re.sub(r"\\(begin|end)\{[^}]*\}", " ", text)
    text = re.sub(r"\\(chapter|section|subsection|subsubsection)\*?\{([^{}]*)\}", r" \2 ", text)
    text = re.sub(r"\\[a-zA-Z@]+\*?(?:\[[^\]]*\])?", " ", text)
    text = text.replace("{", " ").replace("}", " ")
    return text


def cjk_count(text: str) -> int:
    return len(CJK_RE.findall(text))


def split_keywords(value: str) -> list[str]:
    parts = re.split(r"[；;]", value)
    return [p.strip() for p in parts if p.strip()]


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--min-body", type=int, default=8000)
    parser.add_argument("--min-refs", type=int, default=10)
    parser.add_argument("--abstract-min", type=int, default=200)
    parser.add_argument("--abstract-max", type=int, default=300)
    parser.add_argument("--title-max", type=int, default=20)
    parser.add_argument("--min-keywords", type=int, default=3)
    parser.add_argument("--max-keywords", type=int, default=5)
    args = parser.parse_args()

    metadata = read(ROOT / "metadata.tex")
    title = command_value(metadata, "qznutitle")
    abstract = command_value(metadata, "qznuabstracttext")
    keywords = command_value(metadata, "qznukeywords")
    abstract_en = command_value(metadata, "qznuabstractentext")
    keywords_en = command_value(metadata, "qznukeywordsen")
    title_en = command_value(metadata, "qznutitleen")

    body_files = sorted(glob.glob(str(ROOT / "chapters" / "0[1-5]-*.tex")))
    body_text = "\n".join(read(Path(p)) for p in body_files)
    body_count = cjk_count(strip_latex(body_text))

    refs_file = ROOT / "refs.bib"
    refs = re.findall(r"@\w+\{", read(refs_file)) if refs_file.exists() else []

    checks: list[tuple[str, bool, str]] = []
    title_count = cjk_count(title)
    checks.append(("中文题目不超过 %d 字" % args.title_max,
                   title_count <= args.title_max, f"{title_count} 字"))
    abs_count = cjk_count(abstract)
    checks.append(("中文摘要 %d--%d 字" % (args.abstract_min, args.abstract_max),
                   args.abstract_min <= abs_count <= args.abstract_max, f"{abs_count} 字"))
    kws = split_keywords(keywords)
    checks.append(("中文关键词 %d--%d 个" % (args.min_keywords, args.max_keywords),
                   args.min_keywords <= len(kws) <= args.max_keywords, f"{len(kws)} 个"))
    checks.append(("正文不少于 %d 字" % args.min_body,
                   body_count >= args.min_body, f"{body_count} 字"))
    checks.append(("参考文献不少于 %d 篇" % args.min_refs,
                   len(refs) >= args.min_refs, f"{len(refs)} 篇"))
    checks.append(("英文题目非空", bool(title_en.strip()), "已填写" if title_en.strip() else "缺失"))
    checks.append(("英文摘要非空", bool(abstract_en.strip()), "已填写" if abstract_en.strip() else "缺失"))
    checks.append(("英文关键词非空", bool(split_keywords(keywords_en)), "已填写" if keywords_en.strip() else "缺失"))

    width = max(len(name) for name, _, _ in checks)
    failed = 0
    print("内容检查")
    print("-" * (width + 24))
    for name, ok, detail in checks:
        status = "PASS" if ok else "FAIL"
        if not ok:
            failed += 1
        print(f"[{status}] {name:<{width}}  {detail}")
    print("-" * (width + 24))
    print(f"正文文件：{len(body_files)} 个；参考文献条目：{len(refs)} 条")
    if failed:
        print(f"结果：{failed} 项未通过。")
        return 1
    print("结果：全部通过。")
    return 0


if __name__ == "__main__":
    sys.exit(main())
