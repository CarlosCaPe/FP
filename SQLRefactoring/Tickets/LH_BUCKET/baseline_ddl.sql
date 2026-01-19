-- =============================================================================
-- LH_BUCKET Baseline DDL
-- Source: PROD_TARGET.COLLECTIONS.LH_BUCKET_C
-- Target: PROD_WG.LOAD_HAUL.LH_BUCKET
-- =============================================================================
-- Extracted: 2026-01-19
-- =============================================================================

-- Source Table: PROD_TARGET.COLLECTIONS.LH_BUCKET_C
-- This is a TRANSIENT TABLE (not a view) clustered for micro-partition pruning
CREATE OR REPLACE TRANSIENT TABLE LH_BUCKET_C 
CLUSTER BY (ORIG_SRC_ID, SITE_CODE, TRIP_TS_LOCAL::DATE)
(
    BUCKET_ID                       NUMBER(19,0),           -- Business Key
    SITE_CODE                       VARCHAR(4) COLLATE 'en-ci',
    LOADING_CYCLE_ID                NUMBER(19,0),
    EXCAV_ID                        VARCHAR(30),
    ORIG_SRC_ID                     NUMBER(38,0),
    BUCKET_OF_CYCLE                 NUMBER(38,0),
    SWING_EMPTY_START_TS_UTC        TIMESTAMP_NTZ(3),
    SWING_EMPTY_START_TS_LOCAL      TIMESTAMP_NTZ(3),
    SWING_EMPTY_END_TS_UTC          TIMESTAMP_NTZ(3),
    SWING_EMPTY_END_TS_LOCAL        TIMESTAMP_NTZ(3),
    DIG_START_TS_UTC                TIMESTAMP_NTZ(3),
    DIG_START_TS_LOCAL              TIMESTAMP_NTZ(3),
    DIG_END_TS_UTC                  TIMESTAMP_NTZ(3),
    DIG_END_TS_LOCAL                TIMESTAMP_NTZ(3),
    SWING_FULL_START_TS_UTC         TIMESTAMP_NTZ(3),
    SWING_FULL_START_TS_LOCAL       TIMESTAMP_NTZ(3),
    SWING_FULL_END_TS_UTC           TIMESTAMP_NTZ(3),
    SWING_FULL_END_TS_LOCAL         TIMESTAMP_NTZ(3),
    TRIP_TS_UTC                     TIMESTAMP_NTZ(3),
    TRIP_TS_LOCAL                   TIMESTAMP_NTZ(3),       -- Incremental timestamp
    DIG_X                           FLOAT,
    DIG_Y                           FLOAT,
    DIG_Z                           FLOAT,
    TRIP_X                          FLOAT,
    TRIP_Y                          FLOAT,
    TRIP_Z                          FLOAT,
    SWING_ANGLE_DEGREES             FLOAT,
    BLOCK_CENTROID_X                FLOAT,
    BLOCK_CENTROID_Y                FLOAT,
    BLOCK_CENTROID_Z                FLOAT,
    MEASURED_SHORT_TONS             NUMBER(38,6),
    MEASURED_METRIC_TONS            NUMBER(38,6),
    SWING_EMPTY_DURATION_MINS       NUMBER(38,6),
    DIG_DURATION_MINS               NUMBER(38,6),
    SWING_FULL_DURATION_MINS        NUMBER(38,6),
    BUCKET_MATERIAL_ID              NUMBER(19,0),
    SYSTEM_VERSION                  VARCHAR(50) COLLATE 'en-ci',
    DW_LOGICAL_DELETE_FLAG          VARCHAR(1) COLLATE 'en-ci',
    DW_LOAD_TS                      TIMESTAMP_NTZ(0),
    DW_MODIFY_TS                    TIMESTAMP_NTZ(0)
);

-- Target Table: PROD_WG.LOAD_HAUL.LH_BUCKET
-- Note: LH_EQUIP_ID replaces EXCAV_ID, BUCKET_MATERIAL_ID and DW_LOGICAL_DELETE_FLAG removed
CREATE OR REPLACE TABLE LH_BUCKET (
    BUCKET_ID                       NUMBER(19,0),           -- Business Key
    SITE_CODE                       VARCHAR(4) COLLATE 'en-ci',
    LOADING_CYCLE_ID                NUMBER(19,0),
    LH_EQUIP_ID                     NUMBER(38,5),           -- Mapped from EXCAV_ID
    ORIG_SRC_ID                     NUMBER(38,0),
    BUCKET_OF_CYCLE                 NUMBER(38,0),
    SWING_EMPTY_START_TS_UTC        TIMESTAMP_NTZ(3),
    SWING_EMPTY_START_TS_LOCAL      TIMESTAMP_NTZ(3),
    SWING_EMPTY_END_TS_UTC          TIMESTAMP_NTZ(3),
    SWING_EMPTY_END_TS_LOCAL        TIMESTAMP_NTZ(3),
    DIG_START_TS_UTC                TIMESTAMP_NTZ(3),
    DIG_START_TS_LOCAL              TIMESTAMP_NTZ(3),
    DIG_END_TS_UTC                  TIMESTAMP_NTZ(3),
    DIG_END_TS_LOCAL                TIMESTAMP_NTZ(3),
    SWING_FULL_START_TS_UTC         TIMESTAMP_NTZ(3),
    SWING_FULL_START_TS_LOCAL       TIMESTAMP_NTZ(3),
    SWING_FULL_END_TS_UTC           TIMESTAMP_NTZ(3),
    SWING_FULL_END_TS_LOCAL         TIMESTAMP_NTZ(3),
    TRIP_TS_UTC                     TIMESTAMP_NTZ(3),
    TRIP_TS_LOCAL                   TIMESTAMP_NTZ(3),       -- Incremental timestamp
    DIG_X                           FLOAT,
    DIG_Y                           FLOAT,
    DIG_Z                           FLOAT,
    TRIP_X                          FLOAT,
    TRIP_Y                          FLOAT,
    TRIP_Z                          FLOAT,
    SWING_ANGLE_DEGREES             FLOAT,
    BLOCK_CENTROID_X                FLOAT,
    BLOCK_CENTROID_Y                FLOAT,
    BLOCK_CENTROID_Z                FLOAT,
    MEASURED_SHORT_TONS             NUMBER(38,6),
    MEASURED_METRIC_TONS            NUMBER(38,6),
    SWING_EMPTY_DURATION_MINS       NUMBER(38,6),
    DIG_DURATION_MINS               NUMBER(38,6),
    SWING_FULL_DURATION_MINS        NUMBER(38,6),
    SYSTEM_VERSION                  VARCHAR(50) COLLATE 'en-ci',
    DW_LOAD_TS                      TIMESTAMP_NTZ(0),
    DW_MODIFY_TS                    TIMESTAMP_NTZ(0)
);

-- =============================================================================
-- EXISTING PROCEDURES (for reference)
-- =============================================================================
-- PROD_TARGET.DISPATCH.DISPATCH_LH_BUCKET_C_P(8 params) 
-- PROD_TARGET.MSFLEET.FLEET_LH_BUCKET_C_P(8 params)
-- These use the 8-param pattern - need to investigate if we need to follow same pattern

