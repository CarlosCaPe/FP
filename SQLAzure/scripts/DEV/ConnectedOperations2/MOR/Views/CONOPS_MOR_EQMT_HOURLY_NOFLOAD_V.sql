CREATE VIEW [MOR].[CONOPS_MOR_EQMT_HOURLY_NOFLOAD_V] AS

--SELECT * FROM [mor].[CONOPS_MOR_EQMT_HOURLY_NOFLOAD_V] WHERE shiftflag = 'prev'
CREATE VIEW [mor].[CONOPS_MOR_EQMT_HOURLY_NOFLOAD_V]
AS

WITH CTE AS (
SELECT
	shiftindex,
	excav AS Equipment,
	count(excav) AS NofLoad,
	TimeFull_HOS AS HOS
FROM MOR.SHIFT_LOAD_DETAIL_V WITH (NOLOCK)
GROUP BY shiftindex, excav, TimeFull_HOS
)

SELECT
	siteflag,
	shiftflag,
	Equipment,
	SUM(NofLoad) NofLoad,
	HOS,
	dateadd(hour,HOS,ShiftStartDateTime) as TimeinHour
FROM [mor].[CONOPS_MOR_SHIFT_INFO_V] a
LEFT JOIN CTE b on a.SHIFTINDEX = b.SHIFTINDEX
GROUP BY siteflag, shiftflag, Equipment, NofLoad, HOS, ShiftStartDateTime


