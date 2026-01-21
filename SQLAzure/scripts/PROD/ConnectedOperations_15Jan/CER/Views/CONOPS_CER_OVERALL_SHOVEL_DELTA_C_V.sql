CREATE VIEW [CER].[CONOPS_CER_OVERALL_SHOVEL_DELTA_C_V] AS
  
  
--select * from [cer].[CONOPS_CER_OVERALL_SHOVEL_DELTA_C_V]   
CREATE VIEW [cer].[CONOPS_CER_OVERALL_SHOVEL_DELTA_C_V]   
AS  
  
  
WITH CTE AS (  
SELECT  
shiftindex,  
excav,  
COUNT(excav) as NrofLoad,  
SUM(loadtons) as Tons  
FROM dbo.lh_load WITH (NOLOCK)  
WHERE site_code = 'CER'  
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
from [cer].[asset_efficiency] (NOLOCK)  
where unittype = 'Pala'),  
  
ET AS (  
SELECT  
shiftindex,  
eqmtid,  
eqmttype  
FROM [dbo].[LH_EQUIP_LIST] WITH (NOLOCK)  
WHERE SITE_CODE = 'CER'  
AND unit = 'Pala')  
  
SELECT  
a.shiftflag,  
a.siteflag,  
b.excav,  
et.eqmttype,  
SUM(Delta_c * Tons) / SUM(Tons) AS DeltaC,  
ShiftTarget,  
eqmtcurrstatus  
FROM [cer].[CONOPS_CER_SHIFT_INFO_V] a  
LEFT JOIN [DBO].delta_c b WITH (NOLOCK) ON a.shiftindex = b.shiftindex AND b.site_code = 'CER'  
LEFT JOIN ShovelTons c ON a.shiftindex = c.shiftindex AND b.excav = c.excav  
LEFT JOIN STAT d ON a.shiftid = d.shiftid AND b.EXCAV = d.eqmt AND d.num = 1  
LEFT JOIN ET et ON a.shiftindex = et.shiftindex AND b.EXCAV = et.EQMTID  
CROSS JOIN (  
SELECT TOP 1  
Delta_c_target AS ShiftTarget  
FROM [cer].[CONOPS_CER_DELTA_C_TARGET_V] (nolock)) e  
  
GROUP BY a.shiftflag, a.siteflag,ShiftTarget,b.excav,et.eqmttype,eqmtcurrstatus  
  
  
