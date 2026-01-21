CREATE VIEW [sie].[CONOPS_SIE_EQMT_SHOVEL_HOURLY_TPRH_V] AS

--select * from [sie].[CONOPS_SIE_EQMT_SHOVEL_HOURLY_TPRH_V] where shiftflag = 'curr'
CREATE VIEW [sie].[CONOPS_SIE_EQMT_SHOVEL_HOURLY_TPRH_V]
AS

WITH CTE AS (
SELECT
	site_code,
	shiftindex,
	EQMT,
	HOS,
	SUM(ReadyTime) AS ReadyTime
FROM(
	SELECT
		HOS.site_code,
		HOS.shiftindex,
		HOS.EQMT,
		HOS.HOS,
		CASE WHEN HOS.category IN ('1','2') THEN HOS.duration ELSE 0 END AS ReadyTime
	FROM SIE.EQUIPMENT_HOURLY_STATUS (NOLOCK) AS HOS
	WHERE HOS.UNIT = '2' 
) AS sub1
GROUP BY site_code, shiftindex, eqmt, HOS
),

Tons AS (
SELECT 
	siteflag,
	ShiftId,
	excav,
	TimeFull_HOS AS HOS,
	SUM(FieldLSizeTons) AS loadTons
FROM SIE.SHIFT_LOAD_DETAIL_V (NOLOCK)
GROUP BY siteflag, ShiftId, excav, TimeFull_HOS 
)

SELECT
	a.shiftflag,
	a.siteflag,
    DATEADD(hour,b.hos,a.shiftstartdatetime) AS Hr,
    b.EQMT,
    CASE WHEN ReadyTime != 0 THEN c.loadtons/(ReadyTime/3600.0) ELSE 0 END AS TPRH
FROM SIE.CONOPS_SIE_SHIFT_INFO_V a
LEFT JOIN CTE b 
    ON a.shiftindex = b.shiftindex
LEFT JOIN Tons c 
    ON a.ShiftId = c.ShiftId 
    AND b.EQMT = c.excav 
    AND c.HOS = b.HOS


