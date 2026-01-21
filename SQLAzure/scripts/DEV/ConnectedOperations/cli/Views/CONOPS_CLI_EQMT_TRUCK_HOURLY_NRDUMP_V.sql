CREATE VIEW [cli].[CONOPS_CLI_EQMT_TRUCK_HOURLY_NRDUMP_V] AS

--SELECT * FROM [cli].[CONOPS_CLI_EQMT_TRUCK_HOURLY_NRDUMP_V] WHERE shiftflag = 'prev' and equipment = 'C101'
CREATE VIEW [cli].[CONOPS_CLI_EQMT_TRUCK_HOURLY_NRDUMP_V]
AS

WITH CTE AS (
SELECT
	ShiftId,
	truck AS Equipment,
	count(truck) AS NumberofDumps,
	DUMPTIME_HOS AS HOS
FROM CLI.SHIFT_DUMP_DETAIL_V WITH (NOLOCK)
GROUP BY ShiftId, truck, DUMPTIME_HOS
)

SELECT
	siteflag,
	shiftflag,
	Equipment,
	SUM(NumberofDumps) NumberofDumps,
	HOS,
	dateadd(hour,HOS,ShiftStartDateTime) as TimeinHour
FROM [CLI].[CONOPS_CLI_SHIFT_INFO_V] a
LEFT JOIN CTE b
	ON a.ShiftId = b.ShiftId
GROUP BY siteflag, shiftflag, Equipment, NumberofDumps, HOS, ShiftStartDateTime

