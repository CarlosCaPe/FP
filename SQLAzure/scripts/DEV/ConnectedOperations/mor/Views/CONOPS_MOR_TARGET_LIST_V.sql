CREATE VIEW [mor].[CONOPS_MOR_TARGET_LIST_V] AS

CREATE VIEW [MOR].[CONOPS_MOR_TARGET_LIST_V]
AS

WITH TargetPeriod AS (
    SELECT 
        period,
        target,
        CAST(value AS VARCHAR(100)) AS value,
        'MOR_SP_To_SQLMI_PlanValuesProdSum' AS source,
        NULL AS description
    FROM (
        SELECT * FROM (
            SELECT TOP 1
                SUBSTRING(REPLACE(DateEffective, '-', ''), 3, 4) AS period,
                'EFH' AS target,
                EquivalentFlatHaul AS value
            FROM [mor].[plan_values_prod_sum] WITH (NOLOCK)
            ORDER BY DateEffective DESC
        ) AS EFH

        UNION ALL

        SELECT * FROM (
            SELECT TOP 1
                SUBSTRING(REPLACE(DateEffective, '-', ''), 3, 4) AS period,
                'Delta C' AS target,
                DeltaC AS value
            FROM [mor].[plan_values_prod_sum] WITH (NOLOCK)
            ORDER BY DateEffective DESC
        ) AS DeltaC
    ) a
),

TargetShiftId AS (
    SELECT
        Formatshiftid AS shiftid,
        'Shovel Tons' AS target,
        STRING_AGG(CONCAT(Shovel, ': ', Tons), ', ') WITHIN GROUP (ORDER BY Formatshiftid) AS value,
        'MOR_SP_To_SQLMI_PlanValues' AS source,
        NULL AS description
    FROM (
        SELECT DISTINCT 
            Formatshiftid, 
            ISNULL(Shovel, '') AS Shovel,
            SUM(Tons) AS Tons
        FROM [mor].[plan_values] WITH (NOLOCK)
        GROUP BY Formatshiftid, Shovel
    ) a
    GROUP BY Formatshiftid

    UNION ALL

    SELECT 
        shiftid,
        'Mine Productivity' AS target,
        CAST(mineproductivitytarget AS VARCHAR(MAX)) AS value,
        'MOR_SP_To_SQLMI_PlanValues' AS source,
        'Sum of all shovel tons target' AS description
    FROM [mor].[CONOPS_MOR_MINE_PRODUCTIVITY_V]

    UNION ALL

    SELECT
        shiftid,
        'Number of Loads' AS target,
        CAST(SUM(NumberOfLoadsTarget) AS VARCHAR(100)) AS value,
        'MOR_SP_To_SQLMI_PlanValues' AS source,
        'Sum of all shovel tons target / PayloadTarget (267)' AS description
    FROM MOR.CONOPS_MOR_SHOVEL_POPUP WITH (NOLOCK)
    GROUP BY shiftid

    UNION ALL

    SELECT
        shiftid,
        'Average Load Time' AS target,
        CAST(AVG(CAST(LoadTimeTarget AS DECIMAL(10, 2))) AS VARCHAR(100)) AS value,
        NULL AS source,
        'Hardcoded' AS description
    FROM [mor].[CONOPS_MOR_SP_AVG_LOAD_TIME_V]
    GROUP BY shiftid
)

SELECT
    s.siteflag,
    s.shiftflag,
    s.shiftid,
    s.shiftindex,
    t.target,
    t.value,
    t.source,
    t.description
FROM [MOR].[CONOPS_MOR_SHIFT_INFO_V] s
LEFT JOIN TargetShiftId t
    ON s.shiftid = t.shiftid

UNION ALL

SELECT
    s.siteflag,
    s.shiftflag,
    s.shiftid,
    s.shiftindex,
    t.target,
    t.value,
    t.source,
    t.description
FROM [MOR].[CONOPS_MOR_SHIFT_INFO_V] s
LEFT JOIN TargetPeriod t
    ON 1=1;

