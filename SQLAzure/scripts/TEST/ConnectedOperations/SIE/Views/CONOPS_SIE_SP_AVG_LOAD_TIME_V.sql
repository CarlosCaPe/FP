CREATE VIEW [SIE].[CONOPS_SIE_SP_AVG_LOAD_TIME_V] AS
  
  
--SELECT * FROM [sie].[CONOPS_SIE_SP_AVG_LOAD_TIME_V] WHERE SHIFTFLAG = 'CURR'  
CREATE VIEW [sie].[CONOPS_SIE_SP_AVG_LOAD_TIME_V]  
AS  
  
WITH NL AS (  
SELECT  
site_code,  
shiftindex,  
excav,  
avg(loadtime) as loadtime,  
'1.1' AS LoadTimeShiftTarget  
FROM dbo.delta_c WITH (NOLOCK)  
WHERE site_code = 'SIE'  
GROUP BY site_code,shiftindex,excav  
),  
  
  
STAT AS (  
select shiftid,eqmt,reasonidx,reasons,[status] as eqmtcurrstatus,  
ROW_NUMBER() OVER (PARTITION BY shiftid,eqmt ORDER BY startdatetime DESC) num  
FROM sie.asset_efficiency WITH (NOLOCK)  
where unittype = 'shovel')  
  
  
  
  
SELECT  
b.shiftflag,  
b.siteflag,  
b.shiftid,  
b.shiftindex,  
nl.excav,  
b.eqmttype,  
b.payload,  
b.PayloadTarget,  
nl.LoadTime,  
b.LoadingTarget,  
b.LoadingTarget AS LoadTimeTarget,  
nl.LoadTimeShiftTarget,  
b.NumberOfLoads,  
b.NumberOfLoadsTarget,  
b.Operator,  
b.OperatorId,  
b.OperatorImageURL,  
b.TotalMaterialMined,  
b.TotalMaterialMinedTarget,  
b.deltac,  
b.DeltaCTarget,  
b.idletime,  
b.idletimetarget,  
b.spotting,  
b.spottingtarget,  
b.loading,  
b.dumping,  
b.dumpingtarget,  
b.EFH,  
b.EFHtarget,  
b.AssetEfficiency,  
b.AssetEfficiencyTarget,  
b.TonsPerReadyHour,  
b.TonsPerReadyHourTarget,  
b.TotalMaterialMoved,  
b.TotalMaterialMovedTarget,  
b.HangTime,  
b.HangTimeTarget,  
st.reasonidx,  
st.reasons,  
st.eqmtcurrstatus  
FROM NL nl  
LEFT JOIN [sie].[CONOPS_SIE_SHOVEL_POPUP] b WITH (NOLOCK)   
ON nl.shiftindex = b.shiftindex AND nl.EXCAV = b.ShovelID  
LEFT JOIN STAT st on b.shiftid = st.shiftid AND st.eqmt = b.ShovelId AND st.num = 1  
  
WHERE b.shiftflag is not null  
  
  
  
