from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path


@dataclass(frozen=True)
class DownstreamHit:
    folder: str
    file: str
    line: int
    text: str


def find_downstream_references(*, queries_dir: Path, needle: str) -> list[DownstreamHit]:
    """Search QUERIES folders for string references.

    This is intentionally simple (text scan). It complements Snowflake lineage views
    and gives immediate, repo-local dependency hints.
    """
    hits: list[DownstreamHit] = []

    if not needle:
        return hits

    for path in queries_dir.glob("**/*.sql"):
        try:
            text = path.read_text(encoding="utf-8", errors="replace")
        except OSError:
            continue
        if needle not in text:
            continue

        rel = path.relative_to(queries_dir)
        folder = rel.parts[0] if rel.parts else str(rel)

        for i, line in enumerate(text.splitlines(), start=1):
            if needle in line:
                hits.append(
                    DownstreamHit(
                        folder=folder,
                        file=str(rel).replace("\\\\", "/"),
                        line=i,
                        text=line.strip(),
                    )
                )

    return hits
