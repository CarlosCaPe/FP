CREATE VIEW [Arch].[CONOPS_ARCH_SHOVEL_TPRH_V] AS


CREATE VIEW [Arch].[CONOPS_ARCH_SHOVEL_TPRH_V]
AS


SELECT 
stat.shiftindex,
stat.site_code,
EQMT,
CASE WHEN ReadyTime != 0 THEN tons.loadtons/(ReadyTime/3600.0) ELSE 0 END AS TPRH

FROM (
SELECT  site_code,
        shiftindex,
        EQMT,
        SUM(ReadyTime) AS ReadyTime
FROM(
      SELECT HOS.site_code,
             HOS.shiftindex,
             HOS.EQMT,
             CASE WHEN HOS.category IN ('1','2') THEN HOS.duration ELSE 0 END AS ReadyTime
      FROM ARCH.EQUIPMENT_HOURLY_STATUS (NOLOCK) AS HOS
      WHERE HOS.UNIT = '2' 
) AS sub1
GROUP BY site_code,shiftindex,eqmt  

) stat

LEFT JOIN (
SELECT 
Site_code,
shiftindex,
excav,
SUM(loadtons_us) AS loadTons
FROM DBO.LH_LOAD (NOLOCK)
--WHERE site_code = '<SITECODE>'
GROUP BY site_code,shiftindex,excav  
) tons
ON tons.site_code = stat.site_code AND
tons.shiftindex = stat.shiftindex AND
tons.excav = stat.eqmt

WHERE stat.site_code = '<SITECODE>'



