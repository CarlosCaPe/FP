CREATE VIEW [MOR].[CONOPS_MOR_DB_PATTERNS_READY_TO_BLAST_V] AS

--SELECT * FROM MOR.CONOPS_MOR_DB_PATTERNS_READY_TO_BLAST_V
CREATE VIEW MOR.CONOPS_MOR_DB_PATTERNS_READY_TO_BLAST_V
AS

WITH ranked AS (
SELECT
	H.BLASTNAME
	,H.modified_blastname
	,H.STATUS
	,CASE H.STATUS
		WHEN 'Drilled' THEN 1
		WHEN 'Designed' THEN 2
		WHEN 'PartiallyCharged' THEN 2
		WHEN 'Abandoned' THEN 3
		WHEN 'Fired' THEN 3
		END AS hole_complete_ranking
FROM SNOWFLAKE_WG.dbo.BL_DW_HOLE AS H WITH(NOLOCK)
WHERE H.deleted = 0
),

-- Find the mode (most frequent hole_complete_ranking) per BLASTNAME
mode_per_blast AS (
SELECT
	BLASTNAME
	,CASE mode_pick.hole_complete_ranking
		WHEN 1 THEN 'Design In Progress'
		WHEN 2 THEN 'Ready to Blast'
		WHEN 3 THEN 'Blast Complete'
		END AS pattern_status
FROM (
	SELECT 
		BLASTNAME
		,hole_complete_ranking
		,ROW_NUMBER() OVER (
			PARTITION BY BLASTNAME ORDER BY COUNT(*) DESC
				,hole_complete_ranking
			) AS rn
	FROM ranked
	GROUP BY BLASTNAME
		,hole_complete_ranking
	) AS mode_pick
WHERE mode_pick.rn = 1
),

-- Count distinct patterns (modified_blastname) per blast
pattern_counts AS (
SELECT
	BLASTNAME
	,COUNT(DISTINCT modified_blastname) AS pattern_count
FROM ranked
GROUP BY BLASTNAME
)

SELECT DISTINCT
	r.modified_blastname AS blastname
	-- pattern id
	,m.pattern_status
	,CAST(b.VOLUME AS DECIMAL(18, 4)) / NULLIF(pc.pattern_count, 0) AS volume
FROM ranked AS r
JOIN SNOWFLAKE_WG.dbo.BL_DW_BLAST AS b WITH(NOLOCK)
	ON r.BLASTNAME = b.NAME -- Snowflake used HOLE.blastname = BLAST.name
JOIN mode_per_blast AS m ON
	r.BLASTNAME = m.BLASTNAME
JOIN pattern_counts AS pc
	ON r.BLASTNAME = pc.BLASTNAME
WHERE m.pattern_status = 'Ready to Blast'
	--AND LEN(r.modified_blastname) = 10
	--AND TRY_CAST(r.modified_blastname AS INT) IS NOT NULL;


