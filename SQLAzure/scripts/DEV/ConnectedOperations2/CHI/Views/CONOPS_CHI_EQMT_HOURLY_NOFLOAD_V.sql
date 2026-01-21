CREATE VIEW [CHI].[CONOPS_CHI_EQMT_HOURLY_NOFLOAD_V] AS




--SELECT * FROM [chi].[CONOPS_CHI_EQMT_HOURLY_NOFLOAD_V] WHERE shiftflag = 'prev'

CREATE VIEW [chi].[CONOPS_CHI_EQMT_HOURLY_NOFLOAD_V]
AS


WITH CTE AS (
SELECT
shiftindex,
excav AS Equipment,
count(*) AS NofLoad,
HOS
FROM dbo.lh_load WITH (NOLOCK)
where site_code = 'CHI' 
GROUP BY shiftindex,excav,timeload_ts,HOS)

SELECT
siteflag,
shiftflag,
Equipment,
SUM(NofLoad) NofLoad,
HOS,
dateadd(hour,HOS,ShiftStartDateTime) as TimeinHour
FROM [chi].[CONOPS_CHI_SHIFT_INFO_V] a
LEFT JOIN CTE b on a.SHIFTINDEX = b.SHIFTINDEX
GROUP BY siteflag, shiftflag, Equipment, NofLoad, HOS, ShiftStartDateTime

