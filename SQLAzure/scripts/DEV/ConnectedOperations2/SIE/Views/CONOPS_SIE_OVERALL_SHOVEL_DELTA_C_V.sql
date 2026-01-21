CREATE VIEW [SIE].[CONOPS_SIE_OVERALL_SHOVEL_DELTA_C_V] AS
  
 
--select * from [sie].[CONOPS_SIE_OVERALL_SHOVEL_DELTA_C_V]   
CREATE VIEW [sie].[CONOPS_SIE_OVERALL_SHOVEL_DELTA_C_V]   
AS  
  
  
WITH CTE AS (  
SELECT  
shiftindex,  
excav,  
COUNT(excav) as NrofLoad,  
SUM(loadtons) as Tons  
FROM dbo.lh_load WITH (NOLOCK)  
WHERE site_code = 'SIE'  
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
from [SIE].[asset_efficiency] (NOLOCK)  
where unittype = 'shovel'),  
  
ET AS (  
SELECT  
shiftindex,  
eqmtid,  
eqmttype  
FROM [dbo].[LH_EQUIP_LIST] WITH (NOLOCK)  
WHERE SITE_CODE = 'SIE'  
AND unit = 'Shovel')  
  
SELECT  
a.shiftflag,  
a.siteflag,  
b.excav,  
et.eqmttype,  
SUM(Delta_c * Tons) / SUM(Tons) AS DeltaC,  
ShiftTarget,  
eqmtcurrstatus  
FROM [sie].[CONOPS_SIE_SHIFT_INFO_V] a  
LEFT JOIN [DBO].delta_c b WITH (NOLOCK) ON a.shiftindex = b.shiftindex AND b.site_code = 'SIE'  
LEFT JOIN ShovelTons c ON a.shiftindex = c.shiftindex AND b.excav = c.excav  
LEFT JOIN STAT d ON a.shiftid = d.shiftid AND b.EXCAV = d.eqmt AND d.num = 1  
LEfT JOIN ET et ON a.SHIFTINDEX = et.SHIFTINDEX AND b.EXCAV = et.EQMTID  
CROSS JOIN (  
SELECT TOP 1  
DeltaC as Shifttarget  
FROM [sie].[plan_values_prod_sum] (nolock)  
ORDER BY DateEffective DESC) e  
  
  
GROUP BY a.shiftflag, a.siteflag,b.excav,et.eqmttype,ShiftTarget,eqmtcurrstatus  
  
  
  
  
