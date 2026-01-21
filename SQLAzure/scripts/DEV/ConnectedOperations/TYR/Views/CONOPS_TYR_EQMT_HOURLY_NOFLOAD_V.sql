CREATE VIEW [TYR].[CONOPS_TYR_EQMT_HOURLY_NOFLOAD_V] AS

--SELECT * FROM [tyr].[CONOPS_TYR_EQMT_HOURLY_NOFLOAD_V] WHERE shiftflag = 'prev'
CREATE VIEW [TYR].[CONOPS_TYR_EQMT_HOURLY_NOFLOAD_V]
AS

WITH CTE AS (
SELECT
	shiftid,
	excav AS Equipment,
	count(excav) AS NofLoad,
	TimeFull_HOS AS HOS
FROM TYR.SHIFT_LOAD_DETAIL_V WITH (NOLOCK)
--WHERE PayloadFilter = 1
GROUP BY shiftid, excav, TimeFull_HOS
)

SELECT
	siteflag,
	shiftflag,
	Equipment,
	SUM(NofLoad) NofLoad,
	HOS,
	dateadd(hour,HOS,ShiftStartDateTime) as TimeinHour
FROM [TYR].[CONOPS_TYR_SHIFT_INFO_V] a
LEFT JOIN CTE b
	ON a.shiftid = b.shiftid
GROUP BY siteflag, shiftflag, Equipment, NofLoad, HOS, ShiftStartDateTime

