CREATE VIEW [sie].[CONOPS_SIE_TP_DELTA_C_V] AS
  
    
    
--select * FROm [sie].[CONOPS_SIE_TP_DELTA_C_V]    
    
CREATE VIEW [sie].[CONOPS_SIE_TP_DELTA_C_V]     
AS    
    
WITH DELTAC AS (    
SELECT    
shiftindex,    
site_code,    
truck,    
deltac,    
idletime,    
spottime,    
loadtime,    
DumpingTime,    
EFH,    
DumpingAtStockpile,    
DumpingAtCrusher,    
LoadedTravel,    
EmptyTravel    
FROM [sie].[CONOPS_SIE_TP_DELTA_C_AVG_V]),    
    
    
STAT AS (    
select shiftid,eqmt,reasonidx,reasons,[status] as eqmtcurrstatus,    
ROW_NUMBER() OVER (PARTITION BY shiftid,eqmt ORDER BY startdatetime DESC) num    
from [sie].[asset_efficiency] WITH (NOLOCK)    
where unittype = 'truck'),    
    
    
PIT AS (    
select     
ldump.shiftindex,    
ldump.truck,    
case when ldump.dump_blast like '%WT%' THEN 'W COOPER 10'    
when ldump.dump_blast like '%WF%' THEN 'W COOPER 14'    
when ldump.dump_blast like '%SR%' THEN 'SUN RIDGE MINE'    
when ldump.dump_blast like '%AM%' THEN 'AMT MINE'    
when ldump.dump_blast like '%WC%' THEN 'W COOPER'    
when ldump.dump_blast like '%CO%' THEN 'CORONADO'    
when ldump.dump_blast IS NULL THEN 'Other'    
when ldump.grade like '%MILL%' THEN 'Mill Stockpiles'    
ELSE ldump.grade end as Pushback,    
ROW_NUMBER() OVER (PARTITION BY ldump.shiftindex,ldump.truck ORDER BY ldump.TIMEDUMP_TS DESC) row_num    
from dbo.lh_dump ldump WITH (NOLOCK)    
    
WHERE ldump.site_code = 'SIE')    
    
SELECT     
b.shiftflag,    
b.siteflag,    
b.shiftid,    
dc.truck,    
b.eqmttype,    
UPPER(b.operator) as toper,    
b.OperatorImageURL,    
b.OperatorID,    
b.Payload AVG_Payload,    
b.PayloadTarget AVG_PayloadTarget,    
dc.deltac,    
b.DeltaCTarget Delta_c_target,    
dc.idletime,    
b.idletimetarget,    
dc.spottime,    
b.SpottingTarget spottarget,    
dc.loadtime,    
b.LoadingTarget loadtarget,    
dc.DumpingTime,    
b.dumpingtarget,    
dc.EFH,    
b.EFHtarget,    
b.DumpsAtStockpile DumpingAtStockpile,    
b.DumpsAtStockpileTarget dumpingatStockpileTarget,    
b.DumpsAtCrusher DumpingAtCrusher,    
b.DumpsAtCrusherTarget dumpingAtCrusherTarget,    
b.LoadedTravel,    
b.LoadedTravelTarget,    
b.EmptyTravel,    
b.EmptyTravelTarget,    
b.AvgUseOfAvailibility useOfAvailability,    
b.AvgUseOfAvailibilityTarget useOfAvailabilityTarget,    
b.TotalMaterialDelivered,    
b.TotalMaterialDeliveredTarget,    
b.Location [destination],    
pit.Pushback AS Pit,    
stat.reasonidx,    
stat.reasons,    
stat.eqmtcurrstatus    
FROM DELTAC dc    
LEFT JOIN [sie].[CONOPS_SIE_TRUCK_POPUP] b WITH (NOLOCK) ON dc.shiftindex = b.shiftindex AND dc.truck = b.TruckID    
LEFT JOIN STAT stat ON b.shiftid = stat.shiftid AND stat.eqmt = dc.truck AND stat.num = 1    
LEFT JOIN PIT pit ON pit.shiftindex = dc.shiftindex AND pit.TRUCK = dc.truck AND pit.row_num = 1    
    
WHERE b.shiftflag is not null    
    
     
  
