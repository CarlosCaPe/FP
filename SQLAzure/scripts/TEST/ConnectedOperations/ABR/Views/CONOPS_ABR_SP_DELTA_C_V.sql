CREATE VIEW [ABR].[CONOPS_ABR_SP_DELTA_C_V] AS


--SELECT * FROM [abr].[CONOPS_ABR_SP_DELTA_C_V]
CREATE VIEW [ABR].[CONOPS_ABR_SP_DELTA_C_V]
AS


WITH DELTAC AS (
SELECT
shiftindex,
excav,
deltac,
idletime,
spottime,
loadtime,
DumpingTime,
EFH,
EmptyTravel,
LoadedTravel
FROM [abr].[CONOPS_ABR_SP_DELTA_C_AVG_V]
),

STAT AS (
select shiftid,eqmt,reasonidx,reasons,[status] as eqmtcurrstatus,
ROW_NUMBER() OVER (PARTITION BY shiftid,eqmt ORDER BY startdatetime DESC) num
from [abr].[asset_efficiency] (NOLOCK)
where unittype = 'excav')


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
dct.DeltaCTarget,
dc.idletime,
dct.idletimetarget,
dc.spottime as Spotting,
dct.SpottingTarget,
dc.loadtime as Loading,
dct.LoadingTarget,
dc.DumpingTime as Dumping,
dct.dumpingtarget,
dc.EFH,
dct.EFHtarget,
pop.payload,
pop.payloadtarget,
pop.NumberOfLoads,
pop.NumberOfLoadsTarget,
pop.AssetEfficiency,
pop.AssetEfficiencyTarget,
pop.TotalMaterialMoved,  
pop.TotalMaterialMovedTarget,  
pop.HangTime,  
pop.HangTimeTarget, 
pop.TonsPerReadyHour,
pop.TonsPerReadyHourTarget,
stat.reasonidx,
stat.reasons,
stat.eqmtcurrstatus
FROM DELTAC dc
LEFT JOIN [abr].[CONOPS_ABR_SHOVEL_POPUP] [pop] WITH (NOLOCK) 
ON dc.shiftindex = pop.shiftindex AND dc.excav = pop.ShovelID
LEFT JOIN STAT stat ON pop.shiftid = stat.shiftid AND stat.eqmt = dc.excav AND stat.num = 1
LEFT JOIN [ABR].[CONOPS_ABR_DELTA_C_TARGET_V] [dct] ON [pop].shiftid = [dct].shiftid

WHERE pop.shiftflag IS NOT NULL




