#!/usr/bin/env python3
"""Resolve selected packages from a Debian Packages index."""

from __future__ import annotations

import pathlib
import sys


def parse_stanzas(text: str):
    for raw_stanza in text.split("\n\n"):
        fields: dict[str, str] = {}
        current = ""
        for line in raw_stanza.splitlines():
            if line.startswith((" ", "\t")) and current:
                fields[current] += "\n" + line[1:]
                continue
            if ": " not in line:
                continue
            current, value = line.split(": ", 1)
            fields[current] = value
        if fields:
            yield fields


def main() -> int:
    if len(sys.argv) < 3:
        print(
            "usage: debian_package_manifest.py PACKAGES_FILE PACKAGE...",
            file=sys.stderr,
        )
        return 2

    index_path = pathlib.Path(sys.argv[1])
    requested = sys.argv[2:]
    wanted = set(requested)
    resolved: dict[str, dict[str, str]] = {}

    for fields in parse_stanzas(index_path.read_text(encoding="utf-8")):
        package = fields.get("Package", "")
        if package not in wanted:
            continue
        if not all(key in fields for key in ("Filename", "SHA256", "Version")):
            continue
        resolved.setdefault(package, fields)

    missing = [package for package in requested if package not in resolved]
    if missing:
        print(
            "ERROR: packages not found in Debian index: " + ", ".join(missing),
            file=sys.stderr,
        )
        return 1

    for package in requested:
        fields = resolved[package]
        print(
            "|".join(
                (
                    package,
                    fields["Version"],
                    fields["Filename"],
                    fields["SHA256"],
                )
            )
        )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
