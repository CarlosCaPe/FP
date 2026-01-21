CREATE VIEW [Arch].[CONOPS_ARCH_SP_AVG_LOAD_TIME_V] AS



CREATE VIEW [Arch].[CONOPS_ARCH_SP_AVG_LOAD_TIME_V]
AS

WITH NL AS (
SELECT
a.shiftflag,
a.siteflag,
a.shiftid,
a.shiftindex,
b.excav,
b.LoadTime,
'1.1' AS LoadTimeTarget,
'1.1' AS LoadTimeShiftTarget
FROM dbo.SHIFT_INFO_V a

LEFT JOIN (

SELECT 
concat(concat(right(replace(cast(shiftdate as varchar(10)),'-',''),6),'00'),shift_code) as shiftid,
excav,
avg(loadtime) as loadtime
FROM dbo.delta_c WITH (NOLOCK)
--WHERE site_code = '<SITECODE>'
GROUP BY site_code,shiftdate,shift_code,excav) b
ON a.shiftid = b.shiftid AND a.siteflag = '<SITECODE>'

WHERE a.siteflag = '<SITECODE>'
),


STAT AS (
select shiftid,eqmt,reasonidx,reasons,[status] as eqmtcurrstatus,
ROW_NUMBER() OVER (PARTITION BY shiftid,eqmt ORDER BY startdatetime DESC) num
from [Arch].[asset_efficiency] (NOLOCK)
where unittype = 'shovel')




SELECT
nl.shiftflag,
nl.siteflag,
nl.shiftid,
nl.shiftindex,
nl.excav,
b.payload,
b.PayloadTarget,
nl.LoadTime,
nl.LoadTimeTarget,
nl.LoadTimeShiftTarget,
b.NumberOfLoads AS NrofLoad,
b.NumberOfLoadsTarget AS ShovelNrofLoadTarget,
b.Operator AS operatorname,
b.operatorid,
b.TotalMaterialMined as shovelactual,
b.TotalMaterialMinedTarget as shoveltarget,
b.deltac as delta_c,
b.DeltaCTarget as deltac_target,
b.idletime,
b.idletimetarget,
b.spotting,
b.spottingtarget as SpotingTarget,
b.loading,
b.LoadingTarget,
b.dumping,
b.dumpingtarget,
b.EFH,
b.EFHtarget,
b.AssetEfficiency,
b.AssetEfficiencyTarget,
b.TonsPerReadyHour AS TPRH,
b.TonsPerReadyHourTarget AS TPRHTarget,
st.reasonidx,
st.reasons,
st.eqmtcurrstatus
FROM NL nl
LEFT JOIN [Arch].[CONOPS_ARCH_SHOVEL_POPUP_V] b 
ON nl.shiftflag = b.shiftflag AND nl.siteflag = b.siteflag AND nl.EXCAV = b.ShovelID
LEFT JOIN STAT st on nl.shiftid = st.shiftid AND st.eqmt = b.ShovelId 


WHERE nl.siteflag = '<SITECODE>'
AND st.num = 1



