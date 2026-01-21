CREATE VIEW [BAG].[CONOPS_BAG_SHOVEL_TO_WATCH_V] AS
 

--select * from [bag].[CONOPS_BAG_SHOVEL_TO_WATCH_V] where shiftflag = 'prev'  
CREATE VIEW [bag].[CONOPS_BAG_SHOVEL_TO_WATCH_V]  
AS  
  
  
WITH TONS AS (  
SELECT   
shiftid,  
shovelid,  
sum(totalmaterialmined) as tons  
FROM [bag].[CONOPS_BAG_SHIFT_OVERVIEW_V]   
group by shiftid,shovelid),  
  
TGT AS (  
SELECT   
shiftid,  
shovelid,  
sum(shoveltarget) as [target]  
FROM [bag].[CONOPS_BAG_SHOVEL_SHIFT_TARGET_V]  
group by shiftid,shovelid),  
  
STAT AS (  
select shiftid,eqmt,reasonidx,reasons,[status] as eqmtcurrstatus,  
ROW_NUMBER() OVER (PARTITION BY shiftid,eqmt ORDER BY startdatetime DESC) num  
from [bag].[asset_efficiency] WITH (NOLOCK)  
where unittype = 'shovel')  
  
  
SELECT  
a.shiftflag,  
a.siteflag,  
a.shiftid,  
a.shiftindex,  
a.shovelid,  
a.eqmttype,  
a.Operator,  
a.OperatorID,  
a.OperatorImageURL,  
tn.tons as TotalMaterialMined,  
tg.[target] as TotalMaterialMinedTarget,  
(tg.[target] - tn.tons) as OffTarget,  
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
st.reasonidx,  
st.reasons,  
st.eqmtcurrstatus  
FROM TONS tn  
LEFT JOIN TGT tg ON tn.shiftid = tg.SHIFTID AND tn.ShovelId = tg.shovelid  
LEFT JOIN [bag].[CONOPS_BAG_SHOVEL_POPUP] a WITH (NOLOCK) ON tn.shiftid = a.shiftid and tn.ShovelId = a.ShovelID  
LEFT JOIN STAT st ON a.shiftid = st.shiftid AND st.eqmt = a.ShovelID AND st.num = 1  
  
WHERE (tg.[target] - tn.tons) > 0  
  
  
  
  
  
  
  
  
