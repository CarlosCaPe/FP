from dataclasses import dataclass
import subprocess
import webbrowser

import pyodbc
from azure.identity import DeviceCodeCredential


@dataclass(frozen=True)
class Target:
    env: str
    server: str


TARGETS = [
    Target("Dev", "azwd22midbx02.eb8a77f2eea6.database.windows.net"),
    Target("Test", "azwt22midbx02.9959d3e6fe6e.database.windows.net"),
    Target("Prod", "azwp22midbx02.8232c56adfdf.database.windows.net"),
]

DATABASES = [
    "ConnectedOperations",
    "SNOWFLAKE_WG",
]


def get_access_token_bytes() -> bytes:
    def prompt(verification_uri: str, user_code: str, expires_on) -> None:
        msg = (
            f"To sign in, open {verification_uri} and enter the code {user_code}. "
            f"(expires {expires_on})"
        )
        print(msg, flush=True)

        # Best-effort: open default browser.
        try:
            webbrowser.open(verification_uri, new=1)
        except Exception:
            pass

        # Best-effort: copy code to clipboard on Windows.
        try:
            subprocess.run(
                [
                    "powershell",
                    "-NoProfile",
                    "-Command",
                    f"Set-Clipboard -Value '{user_code}'",
                ],
                check=False,
                capture_output=True,
                text=True,
            )
        except Exception:
            pass

    # Prompts once, then reuses cached token until it expires.
    credential = DeviceCodeCredential(
        # This will show a code + URL in the terminal.
        prompt_callback=prompt,
    )
    token = credential.get_token("https://database.windows.net/.default").token
    return token.encode("utf-16-le")


def connect_and_probe(server: str, database: str, access_token_bytes: bytes) -> tuple[str, str, str]:
    # Works with ODBC Driver 17+.
    conn_str = (
        "Driver={ODBC Driver 17 for SQL Server};"
        f"Server=tcp:{server},1433;"
        f"Database={database};"
        "Encrypt=yes;"
        "TrustServerCertificate=no;"
        "Connection Timeout=30;"
        "Authentication=ActiveDirectoryAccessToken;"
    )

    # SQL_COPT_SS_ACCESS_TOKEN = 1256
    conn = pyodbc.connect(conn_str, attrs_before={1256: access_token_bytes})
    try:
        cur = conn.cursor()
        cur.execute("SELECT SUSER_SNAME() AS login_name, DB_NAME() AS db_name, @@SERVERNAME AS server_name")
        row = cur.fetchone()
        return str(row.login_name), str(row.db_name), str(row.server_name)
    finally:
        conn.close()


def main() -> int:
    print("\nAAD sign-in required (device code). You'll be prompted once.\n")
    access_token_bytes = get_access_token_bytes()

    failures: list[str] = []

    for t in TARGETS:
        for db in DATABASES:
            label = f"{t.env} | {t.server} | {db}"
            try:
                login_name, db_name, server_name = connect_and_probe(t.server, db, access_token_bytes)
                print(f"OK  - {label} -> login={login_name} db={db_name} server={server_name}")
            except Exception as e:
                failures.append(f"FAIL- {label} -> {type(e).__name__}: {e}")
                print(f"FAIL- {label} -> {type(e).__name__}: {e}")

    if failures:
        print("\nSummary: failures detected")
        for f in failures:
            print(f"- {f}")
        return 2

    print("\nSummary: all connections succeeded")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
