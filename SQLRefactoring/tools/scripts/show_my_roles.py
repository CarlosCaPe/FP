from __future__ import annotations

from collections import defaultdict

from snowrefactor.snowflake_conn import connect


def _fetchall_dict(cur) -> list[dict[str, object]]:
    cols = [c[0] for c in cur.description]
    return [dict(zip(cols, row)) for row in cur.fetchall()]


BUILTIN_RANK = {
    # Higher is more privileged (typical Snowflake built-in hierarchy)
    "ACCOUNTADMIN": 100,
    "SECURITYADMIN": 90,
    "SYSADMIN": 80,
    "USERADMIN": 70,
    "PUBLIC": 0,
}


def main() -> None:
    with connect() as conn:
        cur = conn.cursor()
        try:
            cur.execute("SELECT CURRENT_USER() AS USER_NAME, CURRENT_ROLE() AS ROLE_NAME")
            user_name, current_role = cur.fetchone()

            print("=" * 100)
            print(f"CURRENT_USER: {user_name}")
            print(f"CURRENT_ROLE: {current_role}")

            # Roles granted directly to the user
            cur.execute(f'SHOW GRANTS TO USER "{user_name}"')
            grants = _fetchall_dict(cur)

            # In SHOW GRANTS TO USER output, role grants show up as:
            # - granted_on = 'ROLE'
            # - name = <role name>
            roles = sorted(
                {
                    str(g.get("name"))
                    for g in grants
                    if str(g.get("granted_on")) == "ROLE" and g.get("name")
                }
            )
            print("=" * 100)
            print(f"Roles granted to user ({len(roles)}):")
            for r in roles:
                print("-", r)

            # Compute parent-role relations among the user's roles using SHOW GRANTS OF ROLE
            parents_map: dict[str, set[str]] = defaultdict(set)
            for r in roles:
                try:
                    cur.execute(f'SHOW GRANTS OF ROLE "{r}"')
                    rows = _fetchall_dict(cur)
                except Exception:
                    continue

                for row in rows:
                    # When a role is granted to another role, SHOW GRANTS OF ROLE includes granted_to = ROLE, name = <parent role>
                    if str(row.get("granted_to")) == "ROLE" and row.get("name"):
                        parent = str(row["name"])
                        parents_map[r].add(parent)

            # Highest roles within the user's role set = those with no parent that is also in the set
            role_set = set(roles)
            roots = []
            for r in roles:
                parents_in_set = sorted(p for p in parents_map.get(r, set()) if p in role_set)
                if not parents_in_set:
                    roots.append(r)

            print("=" * 100)
            print("Role hierarchy (within your role set):")
            for r in roles:
                parents_in_set = sorted(p for p in parents_map.get(r, set()) if p in role_set)
                if parents_in_set:
                    print(f"- {r} -> parent(s): {', '.join(parents_in_set)}")

            print("=" * 100)
            print("Top/most-parent roles (candidates for .env):")
            for r in roots:
                print("-", r)

            # Suggest a 'highest' role: prefer built-ins if present, else pick first root.
            best = None
            best_rank = -1
            for r in roots:
                rank = BUILTIN_RANK.get(r, 10)
                if rank > best_rank:
                    best = r
                    best_rank = rank

            if best:
                print("=" * 100)
                print("SUGGESTED_ROLE_FOR_ENV:")
                print(best)
            else:
                print("=" * 100)
                print("SUGGESTED_ROLE_FOR_ENV:")
                print("<none found>")

        finally:
            cur.close()


if __name__ == "__main__":
    main()
