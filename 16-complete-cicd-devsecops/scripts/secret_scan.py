#!/usr/bin/env python3
"""Fail when common credential formats appear in source-controlled text."""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

IGNORED_DIRECTORIES = {
    ".git",
    ".pytest_cache",
    ".ruff_cache",
    ".venv",
    "__pycache__",
    "build",
    "evidence",
    "htmlcov",
    "reports",
}

PATTERNS = {
    "AWS access key": re.compile(r"AKIA[0-9A-Z]{16}"),
    "GitHub personal access token": re.compile(r"ghp_[A-Za-z0-9]{36}"),
    "private key": re.compile(r"-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----"),
    "assigned credential": re.compile(
        r"(?i)(?:api[_-]?key|password|secret|access[_-]?token)\s*[:=]\s*"
        r"['\"][^'\"\s]{12,}['\"]"
    ),
}


def iter_text_files(root: Path):
    for path in root.rglob("*"):
        ignored = any(part in IGNORED_DIRECTORIES for part in path.parts)
        if not path.is_file() or ignored:
            continue
        try:
            yield path, path.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            continue


def scan(root: Path) -> tuple[int, list[str]]:
    checked = 0
    findings: list[str] = []
    for path, content in iter_text_files(root):
        checked += 1
        for line_number, line in enumerate(content.splitlines(), start=1):
            for label, pattern in PATTERNS.items():
                if pattern.search(line):
                    findings.append(f"{path}:{line_number}: possible {label}")
    return checked, findings


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("root", nargs="?", default=".", type=Path)
    args = parser.parse_args()

    checked, findings = scan(args.root.resolve())
    if findings:
        print("Secret scan failed:")
        print("\n".join(f"  {finding}" for finding in findings))
        return 1

    print(f"Secret scan passed: {checked} text files checked")
    return 0


if __name__ == "__main__":
    sys.exit(main())
