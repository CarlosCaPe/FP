CREATE VIEW [dbo].[PATTERNS_READY_TO_BLAST] AS


create view [dbo].[PATTERNS_READY_TO_BLAST] as 
WITH HoleData AS (
    SELECT 
        HOLE.name,
        HOLE.BLASTNAME,
        HOLE.modified_blastname,
        HOLE.status,
        CASE HOLE.status
            WHEN 'Drilled' THEN 1
            WHEN 'Designed' THEN 2
            WHEN 'PartiallyCharged' THEN 2
            WHEN 'Abandoned' THEN 3
            WHEN 'Fired' THEN 3
        END AS hole_complete_ranking,
        BLAST.VOLUME
    FROM DBO.BL_DW_HOLE AS HOLE
    LEFT JOIN DBO.BL_DW_BLAST AS BLAST
        ON HOLE.blastname = BLAST.name
    WHERE HOLE.deleted = 0
),
PatternStatus AS (
    SELECT 
        BLASTNAME,
        modified_blastname,
        VOLUME,
        -- Emulate MODE() using TOP 1 WITH TIES
        (
            SELECT TOP 1 WITH TIES
                CASE hole_complete_ranking
                    WHEN 1 THEN 'Design In Progress'
                    WHEN 2 THEN 'Ready to Blast'
                    WHEN 3 THEN 'Blast Complete'
                END
            FROM HoleData AS HD2
            WHERE HD2.BLASTNAME = HD.BLASTNAME
            GROUP BY hole_complete_ranking
            ORDER BY COUNT(*) DESC
        ) AS pattern_status
    FROM HoleData AS HD
)
SELECT DISTINCT
    modified_blastname AS blastname,
    pattern_status,
    -- Divide total volume by number of patterns per blast
    VOLUME / COUNT( modified_blastname) OVER (PARTITION BY BLASTNAME) AS volume
FROM PatternStatus
WHERE pattern_status = 'Ready to Blast'
    AND LEN(modified_blastname) = 10
