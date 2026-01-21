CREATE VIEW [CHI].[CONOPS_CHI_SP_AVG_LOAD_TIME_V] AS
  
  
  
  
  
  
--SELECT * FROM [chi].[CONOPS_CHI_SP_AVG_LOAD_TIME_V] WHERE SHIFTFLAG = 'CURR'  
CREATE VIEW [chi].[CONOPS_CHI_SP_AVG_LOAD_TIME_V]  
AS  
  
WITH NL AS (  
  SELECT shiftindex,  
                 excav,  
                 avg(loadtime) AS loadtime,  
     '1.1' AS LoadTimeTarget,  
     '1.1' AS LoadTimeShiftTarget  
          FROM dbo.delta_c WITH (NOLOCK)  
          WHERE site_code = 'CHI'  
          GROUP BY site_code, shiftindex, excav  
),  
  
STAT AS (  
select shiftid,eqmt,reasonidx,reasons,[status] as eqmtcurrstatus,  
ROW_NUMBER() OVER (PARTITION BY shiftid,eqmt ORDER BY startdatetime DESC) num  
from [CHI].[asset_efficiency] (NOLOCK)  
where unittype = 'shovel')  
  
SELECT s.shiftflag,  
       s.siteflag,  
       s.shiftid,  
       nl.shiftindex,  
       nl.excav,  
    s.eqmttype,  
       s.payload,  
    s.payloadtarget,  
       nl.LoadTime,  
       nl.LoadTimeTarget,  
       nl.LoadTimeShiftTarget,  
       s.NumberOfLoads,  
       s.NumberOfLoadsTarget,  
       s.Operator,  
    s.OperatorId,  
       s.OperatorImageURL,  
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
       st.reasonidx,  
       st.reasons,  
       st.eqmtcurrstatus  
FROM NL nl  
LEFT JOIN [chi].[CONOPS_CHI_SHOVEL_POPUP] [s] WITH (NOLOCK)  
ON nl.shiftindex = [s].shiftindex AND nl.excav = [s].ShovelID  
LEFT JOIN STAT st ON st.shiftid = s.shiftid AND st.eqmt = s.ShovelID AND st.num = 1  
  
WHERE s.shiftflag is not null  
  
  
  
  
  
