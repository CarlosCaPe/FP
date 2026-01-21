CREATE VIEW [BAG].[CONOPS_BAG_EQMT_SHOVEL_HOURLY_TPRH_V] AS






--select * from [bag].[CONOPS_BAG_EQMT_SHOVEL_HOURLY_TPRH_V]  where shiftflag = 'curr'
CREATE VIEW [bag].[CONOPS_BAG_EQMT_SHOVEL_HOURLY_TPRH_V] 
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
      FROM [bag].[FLEET_EQUIPMENT_HOURLY_STATUS] (NOLOCK) AS HOS
      WHERE HOS.UNIT = '2' 
) AS sub1
GROUP BY site_code,shiftindex,eqmt,HOS ),

Tons AS (
SELECT
	SITE_CODE AS SITEFLAG,
	SHIFT_ID AS SHIFTID,
	SHOVEL_NAME AS EXCAV,
	LOAD_HOS - 1 AS HOS,
	SUM(REPORT_PAYLOAD_SHORT_TONS) AS LoadTons
FROM BAG.FLEET_SHOVEL_CYCLE_V
GROUP BY SITE_CODE, SHIFT_ID, SHOVEL_NAME, LOAD_HOS)

SELECT
a.shiftflag,
a.siteflag,
DATEADD(hour,b.hos,a.shiftstartdatetime) AS Hr,
b.EQMT,
CASE WHEN ReadyTime != 0 THEN c.loadtons/(ReadyTime/3600.0) ELSE 0 END AS TPRH
FROM BAG.CONOPS_BAG_SHIFT_INFO_V a
LEFT JOIN CTE b ON a.shiftindex = b.shiftindex
LEFT JOIN Tons c ON a.SHIFTID = c.SHIFTID AND b.EQMT = c.excav 
AND c.HOS = b.HOS
--WHERE a.shiftflag = 'prev'
--and b.EQMT = 'S08'





