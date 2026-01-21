CREATE VIEW [MOR].[CONOPS_MOR_SP_DELTA_C_V] AS
  
  
CREATE VIEW [mor].[CONOPS_MOR_SP_DELTA_C_V]  
AS  
  
  
WITH DELTAC AS (  
SELECT  
b.shiftindex,  
b.excav,  
b.deltac,  
b.Delta_c_target,  
b.idletime,  
b.idletimetarget,  
b.spottime,  
b.spottarget,  
b.loadtime,  
b.loadtarget,  
b.DumpingTime,  
b.dumpingtarget,  
b.EFH,  
b.EFHtarget,  
b.EmptyTravel,  
b.emptytraveltarget,  
b.LoadedTravel,  
b.loadedtraveltarget,  
b.AssetEfficiencyTarget  
FROM (  
  
SELECT  
dcavg.shiftindex,  
dcavg.site_code,  
dcavg.excav,  
dcavg.deltac,  
ps.Delta_c_target,  
dcavg.idletime,  
'1.1' as idletimetarget,  
dcavg.spottime,  
ps.spottarget,  
dcavg.loadtime,  
ps.loadtarget,  
dcavg.DumpingTime,  
ps.dumpingtarget,  
dcavg.EFH,  
ps.EFHtarget,  
dcavg.EmptyTravel,  
ps.emptytraveltarget,  
dcavg.LoadedTravel,  
ps.loadedtraveltarget,  
ps.AssetEfficiencyTarget  
FROM [mor].[CONOPS_MOR_SP_DELTA_C_AVG_V] dcavg  
CROSS JOIN (  
SELECT TOP 1  
substring(replace(DateEffective,'-',''),3,4) as shiftdate,DeltaC as Delta_c_target,  
EquivalentFlatHaul as EFHtarget,spoting as spottarget, loading as loadtarget,  
loadingassetefficiency as AssetEfficiencyTarget,  
(DumpingAtCrusher + DumpingatStockpile) as dumpingtarget, loadedtravel as loadedtraveltarget,   
emptytravel as emptytraveltarget  
FROM [mor].[plan_values_prod_sum] (nolock)  
ORDER BY DateEffective DESC) ps  
  
) b   
),  
  
STAT AS (  
select shiftid,eqmt,reasonidx,reasons,[status] as eqmtcurrstatus,  
ROW_NUMBER() OVER (PARTITION BY shiftid,eqmt ORDER BY startdatetime DESC) num  
from [mor].[asset_efficiency] (NOLOCK)  
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
dc.deltac,  
dc.Delta_c_target as DeltaCTarget,  
dc.idletime,  
dc.idletimetarget,  
dc.spottime as Spotting,  
dc.spottarget as SpottingTarget,  
dc.loadtime as Loading,  
dc.loadtarget as LoadingTarget,  
dc.DumpingTime as Dumping,  
dc.dumpingtarget,  
dc.EFH,  
dc.EFHtarget,  
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
LEFT JOIN [mor].[CONOPS_MOR_SHOVEL_POPUP] [pop] WITH (NOLOCK)
ON dc.shiftindex = pop.shiftindex AND dc.excav = pop.ShovelID  
LEFT JOIN STAT stat ON pop.shiftid = stat.shiftid AND stat.eqmt = dc.excav AND stat.num = 1  
  
WHERE pop.shiftflag IS NOT NULL  
  
  
  
  
  
  
