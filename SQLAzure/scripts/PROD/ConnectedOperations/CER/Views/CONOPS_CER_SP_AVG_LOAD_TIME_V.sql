CREATE VIEW [CER].[CONOPS_CER_SP_AVG_LOAD_TIME_V] AS
  
  
--SELECT * FROM [cer].[CONOPS_CER_SP_AVG_LOAD_TIME_V] WHERE SHIFTFLAG = 'CURR'  
CREATE VIEW [cer].[CONOPS_CER_SP_AVG_LOAD_TIME_V]  
AS  
  
WITH NL AS (  
  SELECT shiftindex,  
                 excav,  
                 avg(loadtime) AS loadtime  
     --'1.1' AS LoadTimeTarget,  
     --'1.1' AS LoadTimeShiftTarget  
          FROM dbo.delta_c WITH (NOLOCK)  
          WHERE site_code = 'CER'  
          GROUP BY site_code, shiftindex, excav  
),  
  
STAT AS (  
select shiftid,eqmt,reasonidx,reasons,[status] as eqmtcurrstatus,  
ROW_NUMBER() OVER (PARTITION BY shiftid,eqmt ORDER BY startdatetime DESC) num  
from [CER].[asset_efficiency] (NOLOCK)  
where unittype = 'Pala'),  
  
LoadTarget AS (  
SELECT   
Shiftid,  
loadtarget AS LoadTimeTarget,  
loadtarget AS LoadTimeShiftTarget  
FROM [cer].[CONOPS_CER_DELTA_C_TARGET_V])  
  
SELECT s.shiftflag,  
       s.siteflag,  
       s.shiftid,  
       nl.shiftindex,  
       nl.excav,  
    s.eqmttype,  
       s.payload,  
    s.payloadtarget,  
       nl.LoadTime,  
       tg.LoadTimeTarget,  
       tg.LoadTimeShiftTarget,  
       s.NumberOfLoads,  
       s.NumberOfLoadsTarget,  
       s.Operator,  
    s.OperatorId,  
       s.OperatorImageURL, -- switch from operatorId to personnelId  
       s.TotalMaterialMined,  
       s.TotalMaterialMinedTarget,  
       s.deltac,  
       s.DeltaCTarget,  
       s.idletime,  
       s.idletimetarget,  
       s.spotting,  
       s.SpottingTarget,  
       s.loading,  
       s.LoadingTarget,  
       s.dumping,  
       s.dumpingtarget,  
       s.EFH,  
       s.EFHtarget,  
       s.AssetEfficiency,  
       s.AssetEfficiencyTarget,  
       s.TonsPerReadyHour,  
       s.TonsPerReadyHourTarget,  
    s.TotalMaterialMoved,  
    s.TotalMaterialMovedTarget,  
    s.HangTime,  
    s.HangTimeTarget,  
       stat.reasonidx,  
       stat.reasons,  
       stat.eqmtcurrstatus  
FROM NL nl  
LEFT JOIN [cer].[CONOPS_CER_SHOVEL_POPUP] [s] WITH (NOLOCK)  
ON nl.shiftindex = [s].shiftindex AND nl.excav = [s].ShovelID  
LEFT JOIN STAT stat ON stat.shiftid = s.shiftid AND stat.eqmt = nl.EXCAV AND stat.num = 1  
LEFT JOIN LoadTarget tg ON s.shiftid = tg.ShiftId  
  
WHERE s.shiftflag is not null  
  
  
  
  
  
  
