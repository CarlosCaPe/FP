# SQL Refactoring Tickets

## Overview
This folder contains CT (Change Tracking) refactoring tickets assigned by M. Hidayath.

## Standard Workflow per Table
1. **Create CT table** - Define target table with appropriate columns
2. **Create CT procedure** - Implement MERGE-driven upserts with hash-based conditional updates
3. **Test procedure** - Validate correctness and performance
4. **Schedule task** - Set up recurring execution (typically every 15 minutes)

## Reference Pattern
- **Reference procedure**: `DEV_API_REF.FUSE.DRILLBLAST_DRILL_CYCLE_CT_P`
- **Documentation**: See `QUERIES/PROD_WG__DRILL_BLAST__DRILL_CYCLE/` for detailed patterns
- **Language**: JavaScript stored procedures

## Active Tickets

| Ticket | Source Table | Target Schema | Business Key | Status |
|--------|--------------|---------------|--------------|--------|
| [LH_BUCKET](./LH_BUCKET/) | `PROD_TARGET.COLLECTIONS.LH_BUCKET_C` | `DEV_API_REF.FUSE` | BUCKET_ID | 🟡 DDL Complete |
| [LH_LOADING_CYCLE](./LH_LOADING_CYCLE/) | `PROD_TARGET.COLLECTIONS.LH_LOADING_CYCLE_C` | `DEV_API_REF.FUSE` | LOADING_CYCLE_ID | 🟡 DDL Complete |

## Future Tickets (Mentioned)
- LH_CREW
- LH_EQUIPMENT

## Key Parameters
- **Incremental window**: 3 days
- **Task schedule**: Every 15 minutes
- **Target environment**: `DEV_API_REF.FUSE`

## Deployment Order
Based on dependencies:
1. **LH_BUCKET_CT** (no upstream CT dependencies)
2. **LH_LOADING_CYCLE_CT** (LH_BUCKET references LOADING_CYCLE_ID)

## Tools
- DevOps for pushing changes
- Reference the `tools/` directory for helper scripts
- Snowflake connection via `.env` file in `tools/` folder
