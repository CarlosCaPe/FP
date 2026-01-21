CREATE VIEW [TYR].[CONOPS_TYR_SP_DELTA_C_V] AS



--SELECT * FROM [tyr].[CONOPS_TYR_SP_DELTA_C_V]
CREATE VIEW [TYR].[CONOPS_TYR_SP_DELTA_C_V]
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
FROM [tyr].[CONOPS_TYR_SP_DELTA_C_AVG_V]
),

STAT AS (
select shiftid,eqmt,reasonidx,reasons,[status] as eqmtcurrstatus,
ROW_NUMBER() OVER (PARTITION BY shiftid,eqmt ORDER BY startdatetime DESC) num
from [tyr].[asset_efficiency] (NOLOCK)
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
tg.DeltaCTarget,
dc.idletime,
tg.idletimetarget,
dc.spottime as Spotting,
tg.SpottingTarget,
dc.loadtime as Loading,
tg.LoadingTarget,
dc.DumpingTime as Dumping,
tg.dumpingtarget,
dc.EFH,
tg.EFHtarget,
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
pop.IdleTime AS HangTime,
pop.HangTimeTarget,
stat.reasonidx,
stat.reasons,
stat.eqmtcurrstatus
FROM DELTAC dc
LEFT JOIN [tyr].[CONOPS_TYR_SHOVEL_POPUP_V] [pop] 
ON dc.shiftindex = pop.shiftindex AND dc.excav = pop.ShovelID
LEFT JOIN STAT stat ON pop.shiftid = stat.shiftid AND stat.eqmt = dc.excav AND stat.num = 1
LEFT JOIN [tyr].[CONOPS_TYR_DELTA_C_TARGET_V] [tg] ON [pop].shiftid = [tg].ShiftId
WHERE pop.shiftflag IS NOT NULL






