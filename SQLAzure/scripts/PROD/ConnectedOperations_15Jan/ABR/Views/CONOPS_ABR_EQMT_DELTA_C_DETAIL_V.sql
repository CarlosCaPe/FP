CREATE VIEW [ABR].[CONOPS_ABR_EQMT_DELTA_C_DETAIL_V] AS

CREATE VIEW ABR.CONOPS_ABR_EQMT_DELTA_C_DETAIL_V AS
SELECT 
    site_code,
    shiftindex,
    1 AS eqmttype,
    truck AS eqmt,
    dumpname,
    COUNT(*) AS LoadCount,
    SUM(delta_c) AS MOE_TotalCycle,
    SUM(LT_DELTA) AS MOE_Loaded,
    SUM(ET_DELTA) AS MOE_Empty,
    SUM(DUMPDELTA) AS MOE_Dumping,
    AVG(delta_c) AS DC_TotalCycle,
    AVG(LT_DELTA) AS DC_Loaded,
    AVG(ET_DELTA) AS DC_Empty,
    AVG(DUMPDELTA) AS DC_Dumping,
    AVG(distloaded + (fliftup * 27.1428) + (fliftdown * 16)) AS EFH,
    AVG(TOTALCYCLE) AS AvgCycleTime,
    CASE WHEN SUM(delta_c) = 0 THEN 0
         ELSE (SUM(delta_c) - AVG(TOTALCYCLE)) / SUM(delta_c) * 100 
    END AS CycleEfficiency
FROM dbo.delta_c WITH (NOLOCK)
WHERE site_code = 'ELA'
GROUP BY site_code, shiftindex, truck, dumpname

UNION ALL

SELECT 
    site_code,
    shiftindex,
    2 AS eqmttype,
    excav AS eqmt,
    dumpname,
    COUNT(*) AS LoadCount,
    SUM(delta_c) AS MOE_TotalCycle,
    SUM(LT_DELTA) AS MOE_Loaded,
    SUM(ET_DELTA) AS MOE_Empty,
    SUM(DUMPDELTA) AS MOE_Dumping,
    AVG(delta_c) AS DC_TotalCycle,
    AVG(LT_DELTA) AS DC_Loaded,
    AVG(ET_DELTA) AS DC_Empty,
    AVG(DUMPDELTA) AS DC_Dumping,
    AVG(distloaded + (fliftup * 27.1428) + (fliftdown * 16)) AS EFH,
    AVG(TOTALCYCLE) AS AvgCycleTime,
    CASE WHEN SUM(delta_c) = 0 THEN 0
         ELSE (SUM(delta_c) - AVG(TOTALCYCLE)) / SUM(delta_c) * 100 
    END AS CycleEfficiency
FROM dbo.delta_c WITH (NOLOCK)
WHERE site_code = 'ELA'
GROUP BY site_code, shiftindex, excav, dumpname