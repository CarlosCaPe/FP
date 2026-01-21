CREATE VIEW [bag].[ZZZ_CONOPS_BAG_SHOVEL_TO_WATCH_V_OLD2] AS




--select * from [bag].[CONOPS_BAG_SHOVEL_TO_WATCH_V] where shiftflag = 'prev'
CREATE VIEW [bag].[CONOPS_BAG_SHOVEL_TO_WATCH_V_OLD2]
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
formatshiftid,
shovel,
sum(shovelshifttarget) as [target]
FROM [bag].[CONOPS_BAG_SHOVEL_TARGET_V]
group by formatshiftid,shovel),

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
a.Operator,
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
st.reasonidx,
st.reasons,
st.eqmtcurrstatus
FROM TONS tn
LEFT JOIN TGT tg ON tn.shiftid = tg.FORMATSHIFTID AND tn.ShovelId = tg.shovel
LEFT JOIN [bag].[CONOPS_BAG_SHOVEL_POPUP_V] a ON tn.shiftid = a.shiftid and tn.ShovelId = a.ShovelID
LEFT JOIN STAT st ON a.shiftid = st.shiftid AND st.eqmt = a.ShovelID AND a.siteflag = 'BAG'

WHERE a.siteflag = 'BAG'
AND st.num = 1
AND (tg.[target] - tn.tons) > 0



