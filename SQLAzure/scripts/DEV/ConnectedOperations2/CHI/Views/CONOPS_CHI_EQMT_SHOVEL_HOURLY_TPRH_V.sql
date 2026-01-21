CREATE VIEW [CHI].[CONOPS_CHI_EQMT_SHOVEL_HOURLY_TPRH_V] AS




--select * from [chi].[CONOPS_CHI_EQMT_SHOVEL_HOURLY_TPRH_V] where shiftflag = 'curr'

CREATE VIEW [chi].[CONOPS_CHI_EQMT_SHOVEL_HOURLY_TPRH_V] 
AS


WITH CTE AS (
SELECT  site_code,
        shiftindex,
        EQMT,
		HOS,
        SUM(ReadyTime) AS ReadyTime
FROM(
      SELECT HOS.site_code,
             HOS.shiftindex,
             HOS.EQMT,
			 HOS.HOS,
             CASE WHEN HOS.category IN ('1','2') THEN HOS.duration ELSE 0 END AS ReadyTime
      FROM chi.EQUIPMENT_HOURLY_STATUS (NOLOCK) AS HOS
      WHERE HOS.UNIT = '2' 
) AS sub1
GROUP BY site_code,shiftindex,eqmt,HOS ),

Tons AS (
SELECT 
Site_code,
shiftindex,
excav,
HOS,
SUM(loadtons_us) AS loadTons
FROM DBO.LH_LOAD (NOLOCK)
WHERE Site_code = 'CHI'
GROUP BY site_code,shiftindex,excav,HOS )

SELECT
a.shiftflag,
a.siteflag,
DATEADD(hour,b.hos,a.shiftstartdatetime) AS Hr,
b.EQMT,
CASE WHEN ReadyTime != 0 THEN c.loadtons/(ReadyTime/3600.0) ELSE 0 END AS TPRH
FROM CHI.CONOPS_CHI_SHIFT_INFO_V a
LEFT JOIN CTE b ON a.shiftindex = b.shiftindex
LEFT JOIN Tons c ON a.shiftindex = c.shiftindex AND b.EQMT = c.excav 
AND c.HOS = b.HOS
--WHERE a.shiftflag = 'prev'
--and b.EQMT = 'S08'



