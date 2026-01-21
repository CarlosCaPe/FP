CREATE VIEW [dbo].[BLAST_FACT] AS

CREATE   view [dbo].[BLAST_FACT] as 
/*
WITH hole_rows AS (
    SELECT
        CASE 
            WHEN dplan.site_code = 'MOR' THEN
                CASE 
                    WHEN TRY_CAST(LEFT(dplan.original_plan_id, 3) AS INT) IS NULL THEN SUBSTRING(dplan.original_plan_id, 4, 5)
                    WHEN TRY_CAST(LEFT(dplan.original_plan_id, 10) AS INT) IS NOT NULL THEN dplan.original_plan_id
                    ELSE LEFT(dplan.original_plan_id, 5)
                END
            ELSE dplan.original_plan_id
        END AS pattern_no
    FROM DBO.RCS_DRILLED_HOLE DH
    LEFT JOIN DBO.RCS_DRILL_PLAN DPLAN
        ON DH.SITE_CODE = DPLAN.SITE_CODE
        AND DH.DRILL_PLAN_ID = DPLAN.DRILL_PLAN_ID
    WHERE dh.site_code = 'mor'
)
*/
SELECT
    A.ID, 
    A.NAME,
    A.STATUS,
    CAST(A.FIREDTIME AS DATE) AS BLAST_DATE,
    A.HOLECOUNT AS ACTUAL_HOLE_COUNT,
    CAST(B.PLANNEDDATE AS DATE) AS PLANNED_BLAST_DATE,
    CASE 
        WHEN CAST(A.FIREDTIME AS DATE) = CAST(B.PLANNEDDATE AS DATE) THEN 1
        ELSE 0
    END AS BLAST_DATE_COMPLIANCE,
    A.VOLUME,
    (A.VOLUME * 35.3146667 * 165) / 2000 AS TONS_PER_SHOT,
    COUNT(*) AS pattern_planned_hole_count
FROM DBO.BL_DW_BLAST A
LEFT JOIN DBO.BL_DW_BLASTPROPERTYVALUE B
    ON A.ID = B.BLASTID
--LEFT JOIN hole_rows
--    ON A.NAME = hole_rows.pattern_no
LEFT JOIN DBO.DRILL_PLAN DP
    ON A.NAME = dp.PATTERN_NAME
GROUP BY 
    A.ID, A.NAME, A.STATUS, CAST(A.FIREDTIME AS DATE), A.HOLECOUNT, CAST(B.PLANNEDDATE AS DATE), A.VOLUME;
