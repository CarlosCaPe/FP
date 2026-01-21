CREATE VIEW [bag].[CONOPS_BAG_OPERATOR_HAS_LATE_START_V] AS


  
-- SELECT * FROM [bag].[CONOPS_BAG_OPERATOR_HAS_LATE_START_V] WITH (NOLOCK) WHERE Shiftflag = 'PREV'  
CREATE VIEW [bag].[CONOPS_BAG_OPERATOR_HAS_LATE_START_V]   
AS  

WITH CTE AS (
SELECT
a.SITEFLAG,
a.SHIFTFLAG,
a.SHIFTID,
a.SHIFTINDEX,
SHIFTSTARTDATETIME,
b.EQMTID AS EQMT,     
CASE WHEN b.Unit = 'Haul Truck' THEN 1
WHEN b.unit = 'Shovel' THEN 2 END AS Unit,
UPPER(b.[name]) Operator,
RIGHT('0000000000' + d.OperatorId, 10) OperatorId,
c.Reason AS ShiftState,
MIN (DATEADD(SECOND,b.logintime,a.SHIFTSTARTDATETIME) 
) OVER (PARTITION BY b.operid, a.shiftindex) AS FirstLoginTime,
ROW_NUMBER() OVER (PARTITION BY b.operid, a.shiftindex ORDER BY b.logintime) AS rn  
FROM [bag].[CONOPS_BAG_SHIFT_INFO_V] a
LEFT JOIN [dbo].[LH_OPER_TOTAL_SUM] b WITH (NOLOCK)
ON a.shiftindex = b.SHIFTINDEX 
AND b.SITE_CODE = 'BAG'
AND TRIM(b.operid) NOT IN ('mmsunk', '') 
--AND b.unit_code IN (1, 2)  
and b.unit in ('Shovel','Haul Truck')
AND b.logintime > 900 AND b.logintime < 3600 --Only looks until 1st hour in the Shift 
AND b.logintime <> 0  
LEFT JOIN [bag].[FLEET_PIT_MACHINE_C] d WITH (NOLOCK)
ON a.SHIFTID = d.SHIFTID
AND b.OPERID = d.OperatorId
LEFT JOIN [bag].[FLEET_EQUIPMENT_HOURLY_STATUS] c WITH (NOLOCK)
ON a.SHIFTID = c.SHIFTID 
AND b.EQMTID = c.EQMT
AND c.unit IN (1,2)
AND c.[status] NOT IN (1,2)  --Status not in Production & Down
),

LateStart AS (
SELECT
SITEFLAG,
SHIFTFLAG,
SHIFTID,
d.SHIFTINDEX,
EQMT AS EqmtId,
unit AS UnitCode,
OperatorId,
CASE WHEN OperatorId IS NULL THEN NULL
ELSE CONCAT(lookups.[value],OperatorId,'.jpg') END AS OperatorImageURL,
Operator AS OperatorName,
FirstLoginTime AS FirstLoginDateTime,
ShiftStartDateTime,
LEFT(CAST(FirstLoginTime AS TIME(0)), 5) FirstLoginTime,
UPPER(e.[name]) AS ShiftState
FROM CTE d
LEFT JOIN dbo.LH_REASON e WITH (NOLOCK)
ON d.SHIFTINDEX = e.SHIFTINDEX 
AND e.SITE_CODE = 'BAG' 
AND d.ShiftState = e.REASON
CROSS JOIN dbo.LOOKUPS lookups WITH (NOLOCK)   
WHERE rn = 1
AND lookups.TableCode = 'IMGURL'
),

FirstLoadTruck AS (
SELECT 
SHIFTINDEX,  
SITE_CODE,  
RIGHT('0000000000' + OPER, 10) AS OperatorId,
Truck,
TIMELOAD_TS,  
ROW_NUMBER() OVER (PARTITION BY SHIFTINDEX, OPER ORDER BY TIMELOAD_TS) AS rn  
FROM [dbo].[LH_LOAD] WITH (NOLOCK)  
WHERE SITE_CODE = 'BAG'),

FirstLoadShovel AS (
SELECT 
SHIFTINDEX,  
SITE_CODE,  
RIGHT('0000000000' + EOPER, 10) AS OperatorId,
Excav,
TIMELOAD_TS,  
OPER,
ROW_NUMBER() OVER (PARTITION BY SHIFTINDEX, EOPER ORDER BY TIMELOAD_TS) AS rn  
FROM [dbo].[LH_LOAD] WITH (NOLOCK)  
WHERE SITE_CODE = 'BAG')

SELECT
SITEFLAG,
SHIFTFLAG,
[LateStart].SHIFTID,
LateStart.SHIFTINDEX,
EqmtId,
UnitCode AS unit_code,
[LateStart].OperatorId,
OperatorImageURL,
OperatorName,
FirstLoginDateTime,
ShiftStartDateTime,
FirstLoginTime,
ShiftState,
CASE [LateStart].UnitCode  
WHEN 1 THEN DATEADD(MINUTE, -15, [flt].TIMELOAD_TS)  
WHEN 2 THEN DATEADD(MINUTE, -15, [fls].TIMELOAD_TS)  
ELSE NULL  
END FirstLoadDateTime,  
CASE [LateStart].UnitCode  
WHEN 1 THEN LEFT(CAST(DATEADD(MINUTE, -15, [flt].TIMELOAD_TS) AS TIME(0)), 5)  
WHEN 2 THEN LEFT(CAST(DATEADD(MINUTE, -15, [fls].TIMELOAD_TS) AS TIME(0)), 5)  
ELSE NULL  
END FirstLoadTS
FROM LateStart [LateStart]
LEFT JOIN FirstLoadTruck [flt]  
 ON [LateStart].SHIFTINDEX = [flt].SHIFTINDEX  
    AND [LateStart].OperatorId = [flt].OperatorId  
	AND [LateStart].EqmtId = [flt].TRUCK
    AND [LateStart].UnitCode = 1
    AND [flt].rn = 1  
 LEFT JOIN FirstLoadShovel [fls]  
 ON [LateStart].SHIFTINDEX = [fls].SHIFTINDEX  
    AND [LateStart].OperatorId = [fls].OperatorId  
	AND [LateStart].EqmtId = [fls].EXCAV
    AND [LateStart].UnitCode = 2
    AND [fls].rn = 1  


