from __future__ import annotations

import re
import sys
from pathlib import Path

EXPLAIN_FILES = [
    Path(
        "reports/analyze__PROD_API_REF__CONNECTED_OPERATIONS__SENSOR_SNAPSHOT_GET__20260103_165310__baseline_explain.txt"
    ),
    Path(
        "reports/analyze__PROD_API_REF__CONNECTED_OPERATIONS__SENSOR_SNAPSHOT_GET__20260103_165310__refactor_explain.txt"
    ),
]

TS_RE = re.compile(
    r"->TableScan\s+(?P<table>[^\s]+)(?:\s+as\s+(?P<alias>[^\s]+))?.*?\{partitionsTotal=(?P<pt>\d+),\s*partitionsAssigned=(?P<pa>\d+),\s*bytesAssigned=(?P<ba>\d+)\}",
    re.IGNORECASE,
)


def fmt_bytes(n: int) -> str:
    # binary-ish but readable
    for unit in ["B", "KB", "MB", "GB", "TB", "PB"]:
        if n < 1024 or unit == "PB":
            return f"{n:.2f} {unit}" if unit != "B" else f"{n} B"
        n /= 1024
    return f"{n} B"


def parse_one(path: Path) -> list[dict[str, object]]:
    text = path.read_text(encoding="utf-8", errors="replace")
    rows: list[dict[str, object]] = []
    for m in TS_RE.finditer(text):
        rows.append(
            {
                "table": m.group("table"),
                "alias": m.group("alias") or "",
                "partitionsTotal": int(m.group("pt")),
                "partitionsAssigned": int(m.group("pa")),
                "bytesAssigned": int(m.group("ba")),
            }
        )
    return rows


def main() -> None:
    files = [Path(a) for a in sys.argv[1:]] or EXPLAIN_FILES

    for f in files:
        if not f.exists():
            print(f"Missing: {f}")
            continue

        rows = parse_one(f)
        rows.sort(key=lambda r: int(r["bytesAssigned"]), reverse=True)

        print("=" * 88)
        print(f"EXPLAIN: {f}")
        print(f"TableScan nodes: {len(rows)}")
        print("Top TableScans by bytesAssigned:")
        for r in rows[:30]:
            ba = int(r["bytesAssigned"])
            print(
                f"- {r['table']} {('as ' + r['alias']) if r['alias'] else ''}".rstrip()
                + f" | partitionsAssigned={r['partitionsAssigned']}/{r['partitionsTotal']} | bytesAssigned={ba} ({fmt_bytes(ba)})"
            )

        # Unique table list
        uniq = sorted({str(r["table"]) for r in rows})
        print("\nAll scanned tables (unique):")
        for t in uniq:
            print(f"- {t}")


if __name__ == "__main__":
    main()
