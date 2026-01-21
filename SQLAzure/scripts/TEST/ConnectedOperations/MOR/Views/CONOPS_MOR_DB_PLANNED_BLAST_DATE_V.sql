CREATE VIEW [MOR].[CONOPS_MOR_DB_PLANNED_BLAST_DATE_V] AS

--SELECT * FROM MOR.CONOPS_MOR_DB_PLANNED_BLAST_DATE_V
CREATE VIEW MOR.CONOPS_MOR_DB_PLANNED_BLAST_DATE_V
AS

WITH src AS (
SELECT
	p.BLAST_NAME AS blast_name,
	p.BLAST_DATE_UTC AS plandate,
	ROW_NUMBER() OVER (
		PARTITION BY p.BLAST_NAME
		ORDER BY p.BLAST_DATE_UTC DESC
	) AS rn_src
FROM SNOWFLAKE_WG.dbo.BLAST_PLAN AS p
WHERE
	p.BLAST_DATE_UTC >= DATEADD(day, -30, SYSUTCDATETIME())
	AND p.SITE_CODE = 'MOR'
	-- Optional focus:
	-- AND CHARINDEX('-', p.BLAST_NAME) > 0
	-- AND p.BLAST_NAME = '7045350530-537'
),

src_latest AS (
SELECT
	blast_name,
	plandate
FROM src
WHERE rn_src = 1
),

parts AS (
SELECT
	CASE
		WHEN CHARINDEX('-', blast_name) > 0
			THEN LEFT(blast_name, CHARINDEX('-', blast_name) - 1)
		ELSE blast_name
	END AS part1_raw,
	CASE
		WHEN CHARINDEX('-', blast_name) > 0
			THEN SUBSTRING(
					blast_name,
					CHARINDEX('-', blast_name) + 1,
					LEN(blast_name)
				)
		ELSE NULL
	END AS part2_raw,
	plandate,
	blast_name
FROM src_latest
),

clean AS (
SELECT
	part1_raw AS part1,
	TRY_CONVERT(BIGINT, part1_raw) AS part1_num,			   -- numeric base (handles carry)
	TRY_CONVERT(TINYINT, RIGHT(part1_raw, 1)) AS start_d,	  -- last digit of part1 (for steps)
	/* Last digit among the digits in part2_raw (scan from the right).
	   If part2_raw has no digits, end_d_raw becomes NULL. */
	TRY_CONVERT(TINYINT,
		SUBSTRING(
			REVERSE(part2_raw),
			NULLIF(PATINDEX('%[0-9]%', REVERSE(part2_raw)), 0),
			1
		)
	) AS end_d_raw,
	plandate,
	blast_name
FROM parts
),

limits AS (
SELECT
	*,
	COALESCE(end_d_raw, start_d) AS end_d,					  -- if right part has no digits, end at start
	CASE
		WHEN COALESCE(end_d_raw, start_d) >= start_d
			THEN COALESCE(end_d_raw, start_d) - start_d + 1
		ELSE COALESCE(end_d_raw, start_d) + 10 - start_d + 1
	END AS steps												-- max 10 steps (wrap across 0–9)
FROM clean
),

series AS (
SELECT
	l.*,
	n.s AS i
FROM limits AS l
CROSS APPLY (
	/* Generate integers 0..9 (like Snowflake's GENERATOR + SEQ4()) */
	SELECT v.s
	FROM (VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) AS v(s)
) AS n
WHERE n.s < l.steps
),

finalCTE AS (
SELECT
	blast_name,
	plandate,
	CAST(part1_num + i AS VARCHAR(50)) AS result_value,		 -- whole-number addition to handle carry correctly
	ROW_NUMBER() OVER (
		PARTITION BY CAST(part1_num + i AS VARCHAR(50))
		ORDER BY plandate DESC
	) AS rn
FROM series
)

SELECT
	result_value AS SHOTNO,
	plandate AS PLANDATE
FROM finalCTE
WHERE rn = 1;

--WITH src AS (
--SELECT
--	p.PATTERN_NAME AS SHOTNO,
--	p.BLAST_NAME,
--	p.BLAST_DATE_UTC AS PLANDATE,
--	ROW_NUMBER() OVER (
--		PARTITION BY p.PATTERN_NAME
--		ORDER BY p.BLAST_DATE_UTC DESC
--	) AS rn_src
--FROM SNOWFLAKE_WG.dbo.BLAST_PLAN AS p
--WHERE
--	p.BLAST_DATE_UTC >= DATEADD(day, -30, SYSUTCDATETIME())
--	AND p.SITE_CODE = 'MOR'
--)

--SELECT
--	SHOTNO,
--	BLAST_NAME,
--	PLANDATE
--FROM src
--WHERE rn_src = 1





