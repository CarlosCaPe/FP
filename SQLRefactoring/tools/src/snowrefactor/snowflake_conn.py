from __future__ import annotations

import os
from dataclasses import dataclass

from dotenv import load_dotenv


@dataclass(frozen=True)
class SnowflakeEnv:
    account: str
    user: str
    role: str | None
    warehouse: str | None
    database: str | None
    schema: str | None
    password: str | None
    authenticator: str | None


def load_snowflake_env() -> SnowflakeEnv:
    # Load from .env if present (root). If not present, env vars still work.
    load_dotenv(override=False)

    def req(name: str) -> str:
        value = os.getenv(name)
        if not value:
            raise RuntimeError(f"Missing required env var: {name}")
        return value

    return SnowflakeEnv(
        account=req("CONN_LIB_SNOWFLAKE_ACCOUNT"),
        user=req("CONN_LIB_SNOWFLAKE_USER"),
        role=os.getenv("CONN_LIB_SNOWFLAKE_ROLE"),
        warehouse=os.getenv("CONN_LIB_SNOWFLAKE_WAREHOUSE"),
        database=os.getenv("CONN_LIB_SNOWFLAKE_DATABASE"),
        schema=os.getenv("CONN_LIB_SNOWFLAKE_SCHEMA"),
        password=os.getenv("CONN_LIB_SNOWFLAKE_PASSWORD"),
        authenticator=os.getenv("CONN_LIB_SNOWFLAKE_AUTHENTICATOR"),
    )


def connect():
    import snowflake.connector  # lazy import

    env = load_snowflake_env()

    kwargs: dict[str, object] = {
        "account": env.account,
        "user": env.user,
        # Helps keep sessions stable during long-running DDL/refresh operations.
        "client_session_keep_alive": True,
        # Long-running operations (e.g., Dynamic Table initial refresh) can exceed default network timeouts.
        "network_timeout": 3600,
    }

    if env.password:
        kwargs["password"] = env.password

    if env.authenticator:
        kwargs["authenticator"] = env.authenticator

    if env.role:
        kwargs["role"] = env.role

    if env.warehouse:
        kwargs["warehouse"] = env.warehouse

    if env.database:
        kwargs["database"] = env.database

    if env.schema:
        kwargs["schema"] = env.schema

    try:
        return snowflake.connector.connect(**kwargs)
    except KeyboardInterrupt as e:
        raise RuntimeError(
            "Snowflake login was cancelled (KeyboardInterrupt). If using externalbrowser, rerun the command and complete the browser login without pressing CTRL+C."
        ) from e
    except AttributeError as e:
        # There are rare connector edge-cases after an interrupted externalbrowser flow.
        raise RuntimeError(
            "Snowflake connector failed during authentication (unexpected AttributeError). This can happen after an interrupted ExternalBrowser login. Please rerun the command and complete the browser login."
        ) from e
