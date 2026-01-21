CREATE VIEW [BAG].[CONOPS_BAG_DAILY_OPERATOR_HAS_LATE_START_V] AS

-- SELECT * FROM [bag].[CONOPS_BAG_DAILY_OPERATOR_HAS_LATE_START_V] WITH (NOLOCK) WHERE Shiftflag = 'CURR'
CREATE VIEW [bag].[CONOPS_BAG_DAILY_OPERATOR_HAS_LATE_START_V]
AS

WITH CTE AS (
SELECT
	a.SITEFLAG
	,a.SHIFTFLAG
	,a.SHIFTID
	,a.SHIFTINDEX
	,SHIFTSTARTDATETIME
	,b.MACHINE_NAME AS EQMT
	,b.Unit
	,UPPER(b.OPERATOR_NAME) Operator
	,RIGHT('0000000000' + b.OPERATOR_ID, 10) OperatorId
	,c.Reason AS ShiftState
	,MIN(LOGIN_LOCAL_TIME) OVER (PARTITION BY b.OPERATOR_ID, a.shiftindex) AS FirstLoginTime
FROM bag.CONOPS_BAG_EOS_SHIFT_INFO_V a
LEFT JOIN BAG.FLEET_OPERATOR_SHIFT_V b
	ON a.SHIFTID = b.SHIFTID
	AND b.LOGIN_TIME > 900
	AND b.LOGIN_TIME < 3600 --Only looks until 1st hour in the Shift 
	AND b.LOGIN_TIME <> 0
	AND b.unit IN (1,2)
LEFT JOIN bag.equipment_hourly_status c
	ON a.SHIFTINDEX = c.SHIFTINDEX
	AND b.MACHINE_NAME = c.EQMT
	AND 900 >= c.starttime
	AND 900 < c.endttime
WHERE c.STATUS NOT IN (1,2)
),

LateStart AS (
SELECT SITEFLAG
	,SHIFTFLAG
	,SHIFTID
	,d.SHIFTINDEX
	,EQMT AS EqmtId
	,unit AS UnitCode
	,OperatorId
	,CASE WHEN OperatorId IS NULL THEN NULL 
		ELSE CONCAT (lookups.[value],OperatorId,'.jpg')
		END AS OperatorImageURL
	,Operator AS OperatorName
	,FirstLoginTime AS FirstLoginDateTime
	,ShiftStartDateTime
	,LEFT(CAST(FirstLoginTime AS TIME(0)), 5) FirstLoginTime
	,UPPER(e.REASON) AS ShiftState
FROM CTE d
LEFT JOIN bag.LH_REASON_MAP e WITH (NOLOCK)
	ON d.ShiftState = e.REASON_CODE
CROSS JOIN dbo.LOOKUPS lookups WITH (NOLOCK)
WHERE lookups.TableCode = 'IMGURL'
),

FirstLoadTruck AS (
SELECT
	SITE_CODE,
	SHIFT_ID AS ShiftId,
	TRUCK_NAME AS TRUCK,
	RIGHT('0000000000' + TRUCK_OPERATOR_ID, 10) AS OperatorId,
	CAST(LOADINGSTARTTIME_LOCAL_TS AS DATETIME) AS TIMELOAD_TS,
	ROW_NUMBER() OVER (PARTITION BY SHIFT_ID, TRUCK_OPERATOR_ID ORDER BY LOADINGSTARTTIME_LOCAL_TS) AS rn
FROM bag.fleet_truck_cycle_v
),

FirstLoadShovel AS (
SELECT
	SITE_CODE,
	SHIFT_ID AS ShiftId,
	SHOVEL_NAME AS Excav,
	RIGHT('0000000000' + SHOVEL_OPERATOR_ID, 10) AS OperatorId,
	CAST(LOADINGSTARTTIME_LOCAL_TS AS DATETIME) AS TIMELOAD_TS,
	ROW_NUMBER() OVER (PARTITION BY SHIFT_ID, SHOVEL_OPERATOR_ID ORDER BY LOADINGSTARTTIME_LOCAL_TS) AS rn
FROM bag.fleet_shovel_cycle_v
)

SELECT DISTINCT
	SITEFLAG
	,SHIFTFLAG
	,[LateStart].SHIFTID
	,LateStart.SHIFTINDEX
	,EqmtId
	,UnitCode AS unit_code
	,[LateStart].OperatorId
	,OperatorImageURL
	,OperatorName
	,FirstLoginDateTime
	,ShiftStartDateTime
	,FirstLoginTime
	,ShiftState
	,CASE [LateStart].UnitCode
		WHEN 1 THEN DATEADD(MINUTE, - 15, [flt].TIMELOAD_TS)
		WHEN 2 THEN DATEADD(MINUTE, - 15, [fls].TIMELOAD_TS)
		ELSE NULL
		END FirstLoadDateTime
	,CASE [LateStart].UnitCode
		WHEN 1 THEN LEFT(CAST(DATEADD(MINUTE, - 15, [flt].TIMELOAD_TS) AS TIME(0)), 5)
		WHEN 2 THEN LEFT(CAST(DATEADD(MINUTE, - 15, [fls].TIMELOAD_TS) AS TIME(0)), 5)
		ELSE NULL
		END FirstLoadTS
FROM LateStart [LateStart]
LEFT JOIN FirstLoadTruck [flt]
	ON [LateStart].SHIFTID = [flt].SHIFTID
	AND [LateStart].OperatorId = [flt].OperatorId
	AND [LateStart].EqmtId = [flt].TRUCK
	AND [LateStart].UnitCode = 1
	AND [flt].rn = 1
LEFT JOIN FirstLoadShovel [fls]
	ON [LateStart].SHIFTID = [fls].SHIFTID
	AND [LateStart].OperatorId = [fls].OperatorId
	AND [LateStart].EqmtId = [fls].EXCAV
	AND [LateStart].UnitCode = 2
	AND [fls].rn = 1
WHERE [LateStart].OperatorId IS NOT NULL
