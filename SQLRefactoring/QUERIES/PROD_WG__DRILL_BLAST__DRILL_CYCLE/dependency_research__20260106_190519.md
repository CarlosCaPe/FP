# Dependency research: PROD_WG.DRILL_BLAST.DRILL_CYCLE (VIEW)

Generated (UTC): 2026-01-06T19:05:19Z

Found 1 Dynamic Table dependency(ies).

## PROD_TARGET.COLLECTIONS.DRILLBLAST_DRILL_CYCLE_DT
- show: (not available)
- path: PROD_WG.DRILL_BLAST.DRILL_CYCLE[VIEW] -> PROD_TARGET.COLLECTIONS.DRILLBLAST_DRILL_CYCLE_V[VIEW] -> PROD_TARGET.COLLECTIONS.DRILLBLAST_DRILL_CYCLE_DT[DYNAMIC TABLE]
- ddl: (not available)

Owner action (for stream-on-view enablement):
- If this Dynamic Table uses REFRESH_MODE='FULL', Snowflake requires an IMMUTABLE constraint to support change tracking/streams downstream.
- Use the DDL above as the exact starting point; add an IMMUTABLE constraint only if the DT query is deterministic.
