CREATE VIEW [sie].[CONOPS_SIE_SP_DELTA_C_V] AS

  
  
--SELECT * from [sie].[CONOPS_SIE_SP_DELTA_C_V] where shiftflag = 'prev' order by deltac desc  
  
CREATE VIEW [sie].[CONOPS_SIE_SP_DELTA_C_V]  
AS  
  
WITH DELTAC AS (  
SELECT  
shiftindex,  
site_code,  
excav,  
deltac,  
idletime,  
spottime,  
loadtime,  
DumpingTime,  
EFH,  
EmptyTravel,  
LoadedTravel  
FROM [SIE].[CONOPS_SIE_SP_DELTA_C_AVG_V]  
),  
  
STAT AS (  
select shiftid,eqmt,reasonidx,reasons,[status] as eqmtcurrstatus,  
ROW_NUMBER() OVER (PARTITION BY shiftid,eqmt ORDER BY startdatetime DESC) num  
from [SIE].[asset_efficiency] (NOLOCK)  
where unittype = 'shovel')  
  
  
SELECT   
pop.shiftflag,  
pop.siteflag,  
pop.shiftid,  
pop.shiftindex,  
dc.excav as ShovelID,  
pop.eqmttype,  
pop.Operator,  
pop.OperatorImageURL,  
pop.OperatorID,  
pop.TotalMaterialMined,  
pop.TotalMaterialMinedTarget,  
dc.deltaC,  
pop.DeltaCTarget,  
dc.IdleTime,  
pop.IdleTimeTarget,  
dc.spottime as Spotting,  
pop.SpottingTarget,  
dc.loadtime as Loading,  
pop.LoadingTarget,  
dc.dumpingtime as Dumping,  
pop.DumpingTarget,  
pop.Payload,  
pop.PayloadTarget,  
pop.NumberOfLoads,  
pop.NumberOfLoadsTarget,  
pop.TonsPerReadyHour,  
pop.TonsPerReadyHourTarget,  
pop.AssetEfficiency,  
pop.AssetEfficiencyTarget,  
pop.TotalMaterialMoved,  
pop.TotalMaterialMovedTarget,  
pop.HangTime,  
pop.HangTimeTarget,  
pop.EFH,  
pop.EFHTarget,  
stat.reasonidx,  
stat.reasons,  
stat.eqmtcurrstatus  
FROM DELTAC dc  
LEFT JOIN [SIE].[CONOPS_SIE_SHOVEL_POPUP] [pop] WITH (NOLOCK)
ON dc.shiftindex = pop.shiftindex AND dc.excav = pop.ShovelID  
LEFT JOIN STAT stat ON pop.shiftid = stat.shiftid AND stat.eqmt = dc.excav AND stat.num = 1  
  
WHERE pop.shiftflag IS NOT NULL  
  
  
  
  
  
  

