CREATE VIEW [CHI].[CONOPS_CHI_EQMT_TRUCK_HOURLY_NRDUMP_V] AS

--SELECT * FROM [chi].[CONOPS_CHI_EQMT_TRUCK_HOURLY_NRDUMP_V] WHERE shiftflag = 'prev' and equipment = 'C101'
CREATE VIEW [chi].[CONOPS_CHI_EQMT_TRUCK_HOURLY_NRDUMP_V]
AS

WITH CTE AS (
SELECT
	ShiftId,
	truck AS Equipment,
	count(truck) AS NumberofDumps,
	DUMPTIME_HOS AS HOS
FROM CHI.SHIFT_DUMP_DETAIL_V WITH (NOLOCK)
GROUP BY ShiftId, truck, DUMPTIME_HOS
)

SELECT
	siteflag,
	shiftflag,
	Equipment,
	SUM(NumberofDumps) NumberofDumps,
	HOS,
	dateadd(hour,HOS,ShiftStartDateTime) as TimeinHour
FROM [CHI].[CONOPS_CHI_SHIFT_INFO_V] a
LEFT JOIN CTE b
	ON a.ShiftId = b.ShiftId
GROUP BY siteflag, shiftflag, Equipment, NumberofDumps, HOS, ShiftStartDateTime

