CREATE VIEW [cer].[CONOPS_CER_SP_DELTA_C_V] AS
  
  
  
--select * from [cer].[CONOPS_CER_SP_DELTA_C_V]  
  
CREATE VIEW [cer].[CONOPS_CER_SP_DELTA_C_V]  
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
FROM [CER].[CONOPS_CER_SP_DELTA_C_AVG_V]  
),  
  
STAT AS (  
select shiftid,eqmt,reasonidx,reasons,[status] as eqmtcurrstatus,  
ROW_NUMBER() OVER (PARTITION BY shiftid,eqmt ORDER BY startdatetime DESC) num  
from [CER].[asset_efficiency] (NOLOCK)  
where unittype = 'Pala')  
  
  
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
dc.deltac,  
pop.DeltaCTarget,  
dc.idletime,  
pop.idletimetarget,  
dc.spottime as Spotting,  
pop.SpottingTarget,  
dc.loadtime as Loading,  
pop.LoadingTarget,  
dc.DumpingTime as Dumping,  
pop.dumpingtarget,  
dc.EFH,  
pop.EFHtarget,  
pop.payload,  
pop.payloadtarget,  
pop.NumberOfLoads,  
pop.NumberOfLoadsTarget,  
pop.AssetEfficiency,  
pop.AssetEfficiencyTarget,  
pop.TonsPerReadyHour,  
pop.TonsPerReadyHourTarget,  
pop.TotalMaterialMoved,  
pop.TotalMaterialMovedTarget,  
pop.HangTime,  
pop.HangTimeTarget,  
stat.reasonidx,  
stat.reasons,  
stat.eqmtcurrstatus  
FROM DELTAC dc  
LEFT JOIN [CER].[CONOPS_CER_SHOVEL_POPUP] [pop] WITH (NOLOCK)
ON dc.shiftindex = pop.shiftindex AND dc.excav = pop.ShovelID  
LEFT JOIN STAT stat ON pop.shiftid = stat.shiftid AND stat.eqmt = dc.excav AND stat.num = 1  
  
WHERE pop.shiftflag IS NOT NULL  
  
  
  
  
  
  
