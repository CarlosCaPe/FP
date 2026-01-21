CREATE VIEW [ABR].[CONOPS_ABR_SP_AVG_LOAD_TIME_V] AS





--SELECT * FROM [abr].[CONOPS_ABR_SP_AVG_LOAD_TIME_V] WHERE SHIFTFLAG = 'CURR'
CREATE VIEW [ABR].[CONOPS_ABR_SP_AVG_LOAD_TIME_V]
AS

WITH NL AS (

SELECT 
shiftindex,
excav,
avg(loadtime) as loadtime,
'1.1' AS LoadTimeTarget,
'1.1' AS LoadTimeShiftTarget
FROM dbo.delta_c WITH (NOLOCK)
WHERE site_code = 'ELA'
GROUP BY site_code,shiftindex,excav
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
nl.shiftindex,
nl.excav,
pop.eqmttype,
pop.payload,
pop.PayloadTarget,
nl.LoadTime,
nl.LoadTimeTarget,
nl.LoadTimeShiftTarget,
pop.NumberOfLoads,
pop.NumberOfLoadsTarget,
pop.Operator,
pop.OperatorId,
pop.OperatorImageURL,
pop.TotalMaterialMined,
pop.TotalMaterialMinedTarget,
pop.deltac,
pop.DeltaCTarget,
pop.idletime,
pop.idletimetarget,
pop.spotting,
pop.SpottingTarget,
pop.loading,
pop.LoadingTarget,
pop.dumping,
pop.dumpingtarget,
pop.EFH,
pop.EFHtarget,
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
FROM NL nl
LEFT JOIN [abr].[CONOPS_ABR_SHOVEL_POPUP] [pop] WITH (NOLOCK) 
ON nl.shiftindex = pop.shiftindex AND nl.excav = pop.ShovelID
LEFT JOIN STAT stat ON pop.shiftid = stat.shiftid AND stat.eqmt = nl.excav AND stat.num = 1

WHERE pop.shiftflag IS NOT NULL







