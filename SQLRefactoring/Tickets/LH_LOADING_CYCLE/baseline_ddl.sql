-- =============================================================================
-- LH_LOADING_CYCLE Baseline DDL
-- Source: PROD_TARGET.COLLECTIONS.LH_LOADING_CYCLE_C
-- Target: PROD_WG.LOAD_HAUL.LH_LOADING_CYCLE
-- =============================================================================
-- Extracted: 2026-01-19
-- =============================================================================

-- Source Table: PROD_TARGET.COLLECTIONS.LH_LOADING_CYCLE_C
-- This is a TRANSIENT TABLE clustered for micro-partition pruning
CREATE OR REPLACE TRANSIENT TABLE LH_LOADING_CYCLE_C 
CLUSTER BY (ORIG_SRC_ID, SITE_CODE, SHIFT_ID)
(
    LOADING_CYCLE_ID                NUMBER(19,0),           -- Business Key
    SITE_CODE                       VARCHAR(4) COLLATE 'en-ci',
    ORIG_SRC_ID                     NUMBER(38,0),
    SHIFT_ID                        VARCHAR(12) COLLATE 'en-ci',
    LOADING_CYCLE_OF_SHIFT          NUMBER(38,0),
    EXCAV_CYCLE_OF_SHIFT            NUMBER(38,0),
    CYCLE_START_TS_UTC              TIMESTAMP_NTZ(3),
    CYCLE_START_TS_LOCAL            TIMESTAMP_NTZ(3),       -- Incremental timestamp
    CYCLE_END_TS_UTC                TIMESTAMP_NTZ(3),
    CYCLE_END_TS_LOCAL              TIMESTAMP_NTZ(3),
    MEASURED_PAYLOAD_SHORT_TONS     NUMBER(38,6),
    MEASURED_PAYLOAD_METRIC_TONS    NUMBER(38,6),
    AVG_SWING_DURATION_MINS         NUMBER(38,6),
    AVG_DIG_DURATION_MINS           NUMBER(38,6),
    HANG_DURATION_MINS              NUMBER(38,6),
    IDLE_DURATION_MINS              NUMBER(38,6),
    BUCKET_COUNT                    NUMBER(38,0),
    EXCAV_ID                        NUMBER(19,0),
    TRUCK_ID                        NUMBER(19,0),
    EXCAV                           VARCHAR(50) COLLATE 'en-ci',
    TRUCK                           VARCHAR(50) COLLATE 'en-ci',
    EXCAV_OPERATOR_ID               NUMBER(19,0),
    MATERIAL_ID                     NUMBER(19,0),
    LOADING_LOC_ID                  NUMBER(19,0),
    INTERRUPTED_LOADING_FLAG        NUMBER(1,0),
    ASSOCIATED_HAUL_CYCLE_FLAG      NUMBER(1,0),
    OVER_TRUCKED_FLAG               NUMBER(1,0),
    UNDER_TRUCKED_FLAG              NUMBER(1,0),
    HAUL_CYCLE_ID                   NUMBER(19,0),
    SYSTEM_VERSION                  VARCHAR(50) COLLATE 'en-ci',
    DW_LOGICAL_DELETE_FLAG          VARCHAR(1) COLLATE 'en-ci',
    DW_LOAD_TS                      TIMESTAMP_NTZ(0),
    DW_MODIFY_TS                    TIMESTAMP_NTZ(0)
);

-- Target Table: PROD_WG.LOAD_HAUL.LH_LOADING_CYCLE
-- Note: Missing EXCAV, TRUCK columns; has LOADING_CYCLE_DIG_ELEV columns instead
CREATE OR REPLACE TABLE LH_LOADING_CYCLE (
    LOADING_CYCLE_ID                NUMBER(19,0),           -- Business Key
    SITE_CODE                       VARCHAR(4) COLLATE 'en-ci',
    ORIG_SRC_ID                     NUMBER(38,0),
    SHIFT_ID                        VARCHAR(12) COLLATE 'en-ci',
    LOADING_CYCLE_OF_SHIFT          NUMBER(38,0),
    EXCAV_CYCLE_OF_SHIFT            NUMBER(38,0),
    CYCLE_START_TS_UTC              TIMESTAMP_NTZ(3),
    CYCLE_START_TS_LOCAL            TIMESTAMP_NTZ(3),       -- Incremental timestamp
    CYCLE_END_TS_UTC                TIMESTAMP_NTZ(3),
    CYCLE_END_TS_LOCAL              TIMESTAMP_NTZ(3),
    MEASURED_PAYLOAD_SHORT_TONS     NUMBER(38,6),
    MEASURED_PAYLOAD_METRIC_TONS    NUMBER(38,6),
    AVG_SWING_DURATION_MINS         NUMBER(38,6),
    AVG_DIG_DURATION_MINS           NUMBER(38,6),
    HANG_DURATION_MINS              NUMBER(38,6),
    IDLE_DURATION_MINS              NUMBER(38,6),
    BUCKET_COUNT                    NUMBER(38,0),
    EXCAV_ID                        NUMBER(19,0),
    TRUCK_ID                        NUMBER(19,0),
    EXCAV_OPERATOR_ID               NUMBER(19,0),
    MATERIAL_ID                     NUMBER(19,0),
    LOADING_LOC_ID                  NUMBER(19,0),
    LOADING_CYCLE_DIG_ELEV_AVG_FEET FLOAT,
    LOADING_CYCLE_DIG_ELEV_AVG_METERS FLOAT,
    INTERRUPTED_LOADING_FLAG        NUMBER(1,0),
    ASSOCIATED_HAUL_CYCLE_FLAG      NUMBER(1,0),
    OVER_TRUCKED_FLAG               NUMBER(1,0),
    UNDER_TRUCKED_FLAG              NUMBER(1,0),
    HAUL_CYCLE_ID                   NUMBER(19,0),
    SYSTEM_VERSION                  VARCHAR(50) COLLATE 'en-ci',
    DW_LOAD_TS                      TIMESTAMP_NTZ(0),
    DW_MODIFY_TS                    TIMESTAMP_NTZ(0)
);

-- =============================================================================
-- EXISTING PROCEDURES (for reference)
-- =============================================================================
-- PROD_TARGET.DISPATCH.DISPATCH_LH_LOADING_CYCLE_C_P(8 params)
-- PROD_TARGET.MSFLEET.FLEET_LH_LOADING_CYCLE_C_P(8 params)
-- Various DEV/TEST versions available
