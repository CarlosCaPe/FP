CREATE VIEW [bag].[ZZZ_CONOPS_BAG_SP_NROFLOAD_V_OLD] AS

--SELECT * FROM [bag].[CONOPS_BAG_SP_NROFLOAD_V] WHERE SHIFTFLAG = 'CURR'
CREATE VIEW [bag].[CONOPS_BAG_SP_NROFLOAD_V_OLD]
AS

WITH STAT AS (
select shiftid,eqmt,reasonidx,reasons,[status] as eqmtcurrstatus,
ROW_NUMBER() OVER (PARTITION BY shiftid,eqmt ORDER BY startdatetime DESC) num
from [bag].[asset_efficiency] (NOLOCK)
where unittype = 'shovel')


SELECT
nl.shiftflag,
nl.siteflag,
nl.shiftid,
nl.shiftindex,
nl.shovelid,
nl.payload,
nl.NumberOfLoads AS NrofLoad,
nl.NumberOfLoads AS ShovelNrofLoadTarget,
nl.operator as operatorname,
nl.operatorid,
nl.TotalMaterialMined as shovelactual,
nl.TotalMaterialMinedTarget as shoveltarget,
nl.deltac as delta_c,
nl.DeltaCTarget as deltac_target,
nl.idletime,
nl.idletimetarget,
nl.spotting,
nl.SpottingTarget as SpotingTarget,
nl.loading,
nl.LoadingTarget,
nl.dumping,
nl.dumpingtarget,
nl.EFH,
nl.EFHtarget,
nl.AssetEfficiency,
nl.AssetEfficiencyTarget,
nl.TonsPerReadyHour AS TPRH,
nl.TonsPerReadyHourTarget as TPRHTarget,
st.reasonidx,
st.reasons,
st.eqmtcurrstatus
FROM [bag].[CONOPS_BAG_SHOVEL_POPUP_V] nl
LEFT JOIN STAT st on nl.shiftid = st.shiftid AND st.eqmt = nl.ShovelId


WHERE nl.siteflag = 'BAG'
AND st.num = 1


