CREATE VIEW [SAF].[CONOPS_SAF_SHOVEL_TO_WATCH_V] AS
  
  
  
  
--select * from [saf].[CONOPS_SAF_SHOVEL_TO_WATCH_V] where shiftflag = 'curr'  
CREATE VIEW [saf].[CONOPS_SAF_SHOVEL_TO_WATCH_V]  
AS  
  
WITH STAT AS (  
select shiftid,eqmt,reasonidx,reasons,[status] as eqmtcurrstatus,  
ROW_NUMBER() OVER (PARTITION BY shiftid,eqmt ORDER BY startdatetime DESC) num  
from [saf].[asset_efficiency] WITH (NOLOCK)  
where unittype = 'shovel')  
  
  
SELECT a.shiftflag,  
       a.siteflag,  
       a.shiftid,  
       a.shiftindex,  
       a.shovelid,  
    a.eqmttype,  
       a.Operator,  
    a.OperatorID,  
       a.OperatorImageURL,  
       a.TotalMaterialMined,  
       a.TotalMaterialMinedTarget,  
       (a.TotalMaterialMinedTarget - a.TotalMaterialMined) AS OffTarget,  
       a.deltac,  
       a.DeltaCTarget,  
       a.idletime,  
       a.idletimetarget,  
       a.spotting,  
       a.SpottingTarget,  
       a.loading,  
       a.LoadingTarget,  
       a.dumping,  
       a.dumpingtarget,  
       a.payload,  
       a.payloadTarget,  
       a.NumberOfLoads,  
       a.NumberOfLoadsTarget,  
       a.TonsPerReadyHour,  
       a.TonsPerReadyHourTarget,  
       a.AssetEfficiency,  
       a.AssetEfficiencyTarget,  
    a.Availability,  
    a.AvailabilityTarget,  
    a.TotalMaterialMoved,  
    a.TotalMaterialMovedTarget,  
    a.HangTime,  
    a.HangTimeTarget,  
       b.reasonidx,  
       b.reasons,  
       b.eqmtcurrstatus  
FROM [saf].[CONOPS_SAF_SHOVEL_POPUP] a WITH (NOLOCK)   
LEFT JOIN STAT b on a.shiftid = b.shiftid AND a.ShovelID = b.eqmt AND b.num = 1  
WHERE (a.TotalMaterialMinedTarget - a.TotalMaterialMined) > 0  
  
  
  
  
  
  
