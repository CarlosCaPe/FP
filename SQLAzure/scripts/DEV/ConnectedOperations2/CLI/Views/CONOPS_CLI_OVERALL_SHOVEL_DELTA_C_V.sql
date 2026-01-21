CREATE VIEW [CLI].[CONOPS_CLI_OVERALL_SHOVEL_DELTA_C_V] AS
  
  
--select * from [cli].[CONOPS_CLI_OVERALL_SHOVEL_DELTA_C_V]   
CREATE VIEW [cli].[CONOPS_CLI_OVERALL_SHOVEL_DELTA_C_V]   
AS  
  
  
WITH CTE AS (  
SELECT  
shiftindex,  
excav,  
COUNT(excav) as NrofLoad,  
SUM(loadtons) as Tons  
FROM dbo.lh_load WITH (NOLOCK)  
WHERE site_code = 'CLI'  
GROUP BY shiftindex, excav),  
  
ShovelTons AS (  
SELECT  
shiftindex,  
excav,  
SUM(NrofLoad) NrofLoad,  
SUM(Tons) Tons  
FROM CTE   
GROUP BY shiftindex,excav),  
  
STAT AS (  
select shiftid,eqmt,reasonidx,reasons,[status] as eqmtcurrstatus,  
ROW_NUMBER() OVER (PARTITION BY shiftid,eqmt ORDER BY startdatetime DESC) num  
from [CLI].[asset_efficiency] (NOLOCK)  
where unittype = 'shovel'),  
  
ET AS (  
SELECT  
shiftindex,  
eqmtid,  
eqmttype  
FROM [dbo].[LH_EQUIP_LIST] WITH (NOLOCK)  
WHERE SITE_CODE = 'CLI'  
AND unit = 'Shovel')  
  
SELECT  
a.shiftflag,  
a.siteflag,  
b.excav,  
e.eqmttype,  
SUM(Delta_c * Tons) / SUM(Tons) AS DeltaC,  
8.6 ShiftTarget,  
eqmtcurrstatus  
FROM [cli].[CONOPS_CLI_SHIFT_INFO_V] a  
LEFT JOIN [DBO].delta_c b WITH (NOLOCK) ON a.shiftindex = b.shiftindex AND b.site_code = 'CLI'  
LEFT JOIN ShovelTons c ON a.shiftindex = c.shiftindex AND b.excav = c.excav  
LEFT JOIN STAT d ON a.shiftid = d.shiftid AND b.EXCAV = d.eqmt AND d.num = 1  
LEFT JOIN ET e ON a.SHIFTINDEX = e.SHIFTINDEX AND b.EXCAV = e.EQMTID  
  
GROUP BY a.shiftflag, a.siteflag,b.excav,e.eqmttype,eqmtcurrstatus  
  
  
  
  
