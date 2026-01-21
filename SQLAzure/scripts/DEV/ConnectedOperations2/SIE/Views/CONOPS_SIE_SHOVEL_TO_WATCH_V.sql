CREATE VIEW [SIE].[CONOPS_SIE_SHOVEL_TO_WATCH_V] AS
  
  
--select * from [sie].[CONOPS_SIE_SHOVEL_TO_WATCH_V] where shiftflag = 'prev'  
CREATE VIEW [sie].[CONOPS_SIE_SHOVEL_TO_WATCH_V]  
AS  
  
  
WITH TONS AS (  
SELECT   
shiftid,  
shovelid,  
sum(totalmaterialmoved) as tons  
FROM [sie].[CONOPS_SIE_SHIFT_OVERVIEW_V]   
group by shiftid,shovelid),  
  
/*TGT AS (  
SELECT   
formatshiftid,  
shovel,  
sum(shovelshifttarget) as [target]  
FROM [bag].[CONOPS_BAG_SHOVEL_TARGET_V]  
group by formatshiftid,shovel), --- Need to change to SIE*/  
  
STAT AS (  
select shiftid,eqmt,reasonidx,reasons,[status] as eqmtcurrstatus,  
ROW_NUMBER() OVER (PARTITION BY shiftid,eqmt ORDER BY startdatetime DESC) num  
from [sie].[asset_efficiency] WITH (NOLOCK)  
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
0 as TotalMaterialMinedTarget,  
0 as OffTarget,  
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
--LEFT JOIN TGT tg ON tn.shiftid = tg.FORMATSHIFTID AND tn.ShovelId = tg.shovel  
LEFT JOIN [sie].[CONOPS_SIE_SHOVEL_POPUP] a WITH (NOLOCK) ON tn.shiftid = a.shiftid and tn.ShovelId = a.ShovelID  
LEFT JOIN STAT st ON a.shiftid = st.shiftid AND st.eqmt = a.ShovelID AND st.num = 1  
  
WHERE (0 - tn.tons) > 0  
  
  
  
  
  
  
  
  
