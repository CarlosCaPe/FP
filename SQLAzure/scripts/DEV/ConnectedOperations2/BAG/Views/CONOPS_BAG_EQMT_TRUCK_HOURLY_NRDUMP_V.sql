CREATE VIEW [BAG].[CONOPS_BAG_EQMT_TRUCK_HOURLY_NRDUMP_V] AS





--SELECT * FROM [bag].[CONOPS_BAG_EQMT_TRUCK_HOURLY_NRDUMP_V] WHERE shiftflag = 'prev' and equipment = 'C101'

CREATE VIEW [bag].[CONOPS_BAG_EQMT_TRUCK_HOURLY_NRDUMP_V]
AS

WITH CTE AS (
SELECT
	SITE_CODE AS SITEFLAG,
	SHIFT_ID AS SHIFTID,
	TRUCK_NAME AS EQUIPMENT,
	DUMP_HOS - 1 AS HOS,
	COUNT(*) AS NumberOfDumps
FROM BAG.FLEET_TRUCK_CYCLE_V
GROUP BY SITE_CODE, SHIFT_ID, TRUCK_NAME, DUMP_HOS)

SELECT
a.siteflag,
shiftflag,
Equipment,
SUM(NumberofDumps) NumberofDumps,
HOS,
dateadd(hour,HOS,ShiftStartDateTime) as TimeinHour
FROM [bag].[CONOPS_BAG_SHIFT_INFO_V] a
LEFT JOIN CTE b on a.SHIFTID = b.SHIFTID
GROUP BY a.siteflag, shiftflag, Equipment, NumberofDumps, HOS, ShiftStartDateTime




