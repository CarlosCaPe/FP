from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any

import yaml


@dataclass(frozen=True)
class QueryConfig:
    primary_key: list[str] | None = None
    order_by: list[str] | None = None
    max_fetch_rows: int | None = None
    ignore_columns: list[str] | None = None


def load_query_config(folder: Path) -> QueryConfig:
    cfg_path = folder / "config.yml"
    if not cfg_path.exists():
        return QueryConfig()

    data: dict[str, Any] = yaml.safe_load(cfg_path.read_text(encoding="utf-8")) or {}
    pk = data.get("primary_key")
    order_by = data.get("order_by")
    max_fetch_rows = data.get("max_fetch_rows")
    ignore_columns = data.get("ignore_columns")

    def _list_or_none(value: Any) -> list[str] | None:
        if value is None:
            return None
        if isinstance(value, str):
            return [value]
        if isinstance(value, list) and all(isinstance(x, str) for x in value):
            return value
        raise ValueError(f"Invalid list value in {cfg_path}: {value!r}")

    return QueryConfig(
        primary_key=_list_or_none(pk),
        order_by=_list_or_none(order_by),
        max_fetch_rows=int(max_fetch_rows) if max_fetch_rows is not None else None,
        ignore_columns=_list_or_none(ignore_columns),
    )
