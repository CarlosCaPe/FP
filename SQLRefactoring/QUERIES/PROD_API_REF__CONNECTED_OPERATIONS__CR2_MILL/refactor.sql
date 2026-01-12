-- Refactor (dbt-style naming): src_* -> agg_* -> final
-- Goal: identical output + better readability/maintainability.
-- Note: Keep table function arguments as literals (as in baseline DDL)
-- to avoid Snowflake internal errors seen with parameterized arrays/args.

WITH
src_vars AS (
	SELECT
		'MOR'::STRING AS site_code,
		CAST(CONVERT_TIMEZONE('UTC', CURRENT_TIMESTAMP) AS TIMESTAMP_NTZ) AS utc_created_date
),

src_shift AS (
	SELECT
		MAX(d.shiftindex) AS shiftindex
	FROM PROD_API_REF.CONNECTED_OPERATIONS.lh_shift_date d
	WHERE d.site_code = 'MOR'
),

src_sensor_snapshot AS (
	SELECT
		s.tag_name,
		s.sensor_value
	FROM TABLE(
		SANDBOX_DATA_ENGINEER.CCARRILL2.SENSOR_SNAPSHOT_GET(
			'MOR',
			FALSE,
			ARRAY_CONSTRUCT(''),
			ARRAY_CONSTRUCT(
				'CR03_CRUSH_OUT_TIME',
				'PE_MOR_CC_MflPileTonnage',
				'PE_MOR_CC_MillPileTonnage'
			)
		)
	) s
),

agg_mapped AS (
	SELECT
		sh.shiftindex AS shiftindex,
		'MOR' AS siteflag,
		CASE ss.tag_name
			WHEN 'CR03_CRUSH_OUT_TIME' THEN 'CrusherCR2ToMill'
			WHEN 'PE_MOR_CC_MflPileTonnage' THEN 'CrusherMFLIOS'
			WHEN 'PE_MOR_CC_MillPileTonnage' THEN 'CrusherMillIOS'
		END AS component,
		ss.sensor_value,
		v.utc_created_date
	FROM src_vars v
	CROSS JOIN src_shift sh
	JOIN src_sensor_snapshot ss
		ON 1 = 1
),

final AS (
	SELECT
		shiftindex,
		siteflag,
		component,
		sensor_value,
		utc_created_date
	FROM agg_mapped
)

SELECT *
FROM final;
