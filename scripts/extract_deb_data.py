#!/usr/bin/env python3
"""Extract the data archive from a Debian ar package."""

from __future__ import annotations

import pathlib
import sys


def main() -> int:
    if len(sys.argv) != 3:
        print("usage: extract_deb_data.py PACKAGE.deb OUTPUT_DIR", file=sys.stderr)
        return 2

    package = pathlib.Path(sys.argv[1])
    output_dir = pathlib.Path(sys.argv[2])
    output_dir.mkdir(parents=True, exist_ok=True)

    with package.open("rb") as source:
        if source.read(8) != b"!<arch>\n":
            raise SystemExit(f"not a Debian ar archive: {package}")

        while header := source.read(60):
            if len(header) != 60 or header[58:60] != b"`\n":
                raise SystemExit(f"invalid ar member header in {package}")

            name = header[:16].decode("ascii").strip().rstrip("/")
            size = int(header[48:58].decode("ascii").strip())
            data = source.read(size)
            if size & 1:
                source.read(1)

            if name.startswith("data.tar"):
                target = output_dir / name
                target.write_bytes(data)
                print(target)
                return 0

    raise SystemExit(f"data archive not found in {package}")


if __name__ == "__main__":
    raise SystemExit(main())
