-- Refactor DDL for sandbox deployment
-- Goals:
-- 1) Add lookback-days parameter (default 30) without breaking old callers.
-- 2) Preserve output columns and semantics.
-- 3) Keep the baseline filter behavior: RAW.SITE_CODE = PARAM_SITE_CODE.
--
-- Note on Dynamic Tables:
-- We attempted a Dynamic Table materialization strategy, but it is not safe here:
-- - The initial refresh for some sources exceeds the 1-hour warehouse timeout.
-- - Even when created, results can be stale vs the baseline function (checksum mismatch).
--
-- This refactor stays fully on-demand and semantics-preserving.

CREATE OR REPLACE FUNCTION "SENSOR_SNAPSHOT_GET"(
  "PARAM_SITE_CODE" VARCHAR(3),
  "PARAM_IS_AF_PATH_FLAG" BOOLEAN,
  "PARAM_ATTRIBUTE_PATH_LIST" ARRAY,
  "PARAM_PI_POINT_LIST" ARRAY,
  "PARAM_LOOKBACK_DAYS" NUMBER(38,0)
)
RETURNS TABLE (
  "TAG_NAME" VARCHAR(16777216),
  "VALUE_UTC_TS" TIMESTAMP_NTZ(9),
  "SENSOR_VALUE" VARCHAR(16777216),
  "UOM" VARCHAR(16777216),
  "QUALITY" VARCHAR(16777216)
)
LANGUAGE SQL
AS '
WITH src_params AS (
  SELECT
    NULLIF(TRIM(PARAM_SITE_CODE), '''') AS site_code,
    IFF(PARAM_LOOKBACK_DAYS IS NULL OR PARAM_LOOKBACK_DAYS <= 0, 30, PARAM_LOOKBACK_DAYS) AS lookback_days
),

int_cutoff AS (
  SELECT
    p.site_code,
    p.lookback_days,
    CAST(
      DATEADD(''day'', -p.lookback_days, CURRENT_TIMESTAMP(0))
      AS TIMESTAMP_NTZ
    ) AS min_value_utc_ts
  FROM src_params p
),

src_attribute_paths AS (
  SELECT
    VALUE::STRING AS attributepath
  FROM TABLE(FLATTEN(INPUT => PARAM_ATTRIBUTE_PATH_LIST))
  WHERE VALUE IS NOT NULL
    AND TRIM(VALUE::STRING) <> ''''
),

src_pi_points AS (
  SELECT
    VALUE::STRING AS pipointname
  FROM TABLE(FLATTEN(INPUT => PARAM_PI_POINT_LIST))
  WHERE VALUE IS NOT NULL
    AND TRIM(VALUE::STRING) <> ''''
),

src_pi_af_attribute AS (
  SELECT
    a.sensor_id,
    a.attributepath
  FROM PROD_DATALAKE.FCTS.PI_AF_ATTRIBUTE a
),

src_pi_point AS (
  SELECT
    p.sensor_id,
    p.pipointname
  FROM PROD_DATALAKE.FCTS.PI_POINT p
),

int_sensor_id_af AS (
  SELECT
    a.sensor_id
  FROM src_pi_af_attribute a
  JOIN src_attribute_paths ap
    ON a.attributepath = ap.attributepath
  WHERE PARAM_IS_AF_PATH_FLAG = TRUE
  GROUP BY a.sensor_id
),

int_sensor_id_pi AS (
  SELECT
    p.sensor_id
  FROM src_pi_point p
  JOIN src_pi_points pp
    ON p.pipointname = pp.pipointname
  WHERE PARAM_IS_AF_PATH_FLAG = FALSE
  GROUP BY p.sensor_id
),

int_sensor_id AS (
  SELECT sensor_id FROM int_sensor_id_af
  UNION ALL
  SELECT sensor_id FROM int_sensor_id_pi
),

int_sensor_id_distinct AS (
  SELECT sensor_id
  FROM int_sensor_id
  GROUP BY sensor_id
),

-- Latest row per sensor_id (within lookback) with a single scan against ONLY the requested site table.
-- Use RANK() (not ROW_NUMBER) to preserve baseline behavior when multiple rows share the same max VALUE_UTC_TS.
int_latest_rows AS (
  SELECT
    raw.sensor_id,
    raw.value_utc_ts,
    raw.sensor_value,
    raw.uom,
    raw.quality
  FROM IDENTIFIER(
    CASE UPPER(PARAM_SITE_CODE)
      WHEN ''SAM'' THEN ''SANDBOX_DATA_ENGINEER.CCARRILL2.FCTS_SENSOR_READING_SAM_B''
      WHEN ''MOR'' THEN ''SANDBOX_DATA_ENGINEER.CCARRILL2.FCTS_SENSOR_READING_MOR_B''
      WHEN ''CMX'' THEN ''SANDBOX_DATA_ENGINEER.CCARRILL2.FCTS_SENSOR_READING_CMX_B''
      WHEN ''SIE'' THEN ''SANDBOX_DATA_ENGINEER.CCARRILL2.FCTS_SENSOR_READING_SIE_B''
      WHEN ''NMO'' THEN ''SANDBOX_DATA_ENGINEER.CCARRILL2.FCTS_SENSOR_READING_NMO_B''
      WHEN ''BAG'' THEN ''SANDBOX_DATA_ENGINEER.CCARRILL2.FCTS_SENSOR_READING_BAG_B''
      WHEN ''CVE'' THEN ''SANDBOX_DATA_ENGINEER.CCARRILL2.FCTS_SENSOR_READING_CVE_B''
    END
  ) raw
  JOIN int_cutoff c
    ON 1 = 1
  JOIN int_sensor_id_distinct sid
    ON raw.sensor_id = sid.sensor_id
  WHERE raw.site_code = PARAM_SITE_CODE
    AND raw.value_utc_ts > c.min_value_utc_ts
  QUALIFY RANK() OVER (PARTITION BY raw.sensor_id ORDER BY raw.value_utc_ts DESC) = 1
),

int_annotations AS (
  SELECT
    a.sensor_id,
    a.attributepath
  FROM src_pi_af_attribute a
  JOIN src_attribute_paths ap
    ON a.attributepath = ap.attributepath
)

SELECT
  CASE
    WHEN PARAM_IS_AF_PATH_FLAG THEN REPLACE(ANNT.ATTRIBUTEPATH,''\\DataReference'')::VARCHAR
    ELSE POINT.PIPOINTNAME
  END AS TAG_NAME,
  L.VALUE_UTC_TS,
  L.SENSOR_VALUE::VARCHAR,
  L.UOM::VARCHAR,
  L.QUALITY::VARCHAR
FROM int_latest_rows L
LEFT JOIN int_annotations ANNT
  ON L.SENSOR_ID = ANNT.SENSOR_ID
LEFT JOIN src_pi_point POINT
  ON L.SENSOR_ID = POINT.SENSOR_ID
';

-- Backward-compatible 4-arg wrapper (defaults lookback to 30 days)
CREATE OR REPLACE FUNCTION "SENSOR_SNAPSHOT_GET"(
  "PARAM_SITE_CODE" VARCHAR(3),
  "PARAM_IS_AF_PATH_FLAG" BOOLEAN,
  "PARAM_ATTRIBUTE_PATH_LIST" ARRAY,
  "PARAM_PI_POINT_LIST" ARRAY
)
RETURNS TABLE (
  "TAG_NAME" VARCHAR(16777216),
  "VALUE_UTC_TS" TIMESTAMP_NTZ(9),
  "SENSOR_VALUE" VARCHAR(16777216),
  "UOM" VARCHAR(16777216),
  "QUALITY" VARCHAR(16777216)
)
LANGUAGE SQL
AS '
  WITH final AS (
    SELECT
      t.tag_name,
      t.value_utc_ts,
      t.sensor_value,
      t.uom,
      t.quality
    FROM TABLE("SENSOR_SNAPSHOT_GET"(
      PARAM_SITE_CODE,
      PARAM_IS_AF_PATH_FLAG,
      PARAM_ATTRIBUTE_PATH_LIST,
      PARAM_PI_POINT_LIST,
      30
    )) t
  )
  SELECT * FROM final
';
