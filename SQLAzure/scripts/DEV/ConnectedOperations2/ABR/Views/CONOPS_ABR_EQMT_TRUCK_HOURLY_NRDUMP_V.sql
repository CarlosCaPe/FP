CREATE VIEW [ABR].[CONOPS_ABR_EQMT_TRUCK_HOURLY_NRDUMP_V] AS


--SELECT * FROM [abr].[CONOPS_ABR_EQMT_TRUCK_HOURLY_NRDUMP_V] WHERE shiftflag = 'prev' and equipment = 'C101'

CREATE VIEW [ABR].[CONOPS_ABR_EQMT_TRUCK_HOURLY_NRDUMP_V]
AS

WITH CTE AS (
SELECT
shiftindex,
truck AS Equipment,
count(truck) AS NumberofDumps,
HOS
FROM dbo.lh_load WITH (NOLOCK)
where site_code = 'ELA' 
GROUP BY shiftindex,truck,timeload_ts,HOS)

SELECT
siteflag,
shiftflag,
Equipment,
SUM(NumberofDumps) NumberofDumps,
HOS,
dateadd(hour,HOS,ShiftStartDateTime) as TimeinHour
FROM [abr].[CONOPS_ABR_SHIFT_INFO_V] a
LEFT JOIN CTE b on a.SHIFTINDEX = b.SHIFTINDEX
GROUP BY siteflag, shiftflag, Equipment, NumberofDumps, HOS, ShiftStartDateTime



