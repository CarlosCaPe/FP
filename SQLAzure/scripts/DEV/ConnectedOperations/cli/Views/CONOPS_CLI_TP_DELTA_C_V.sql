CREATE VIEW [cli].[CONOPS_CLI_TP_DELTA_C_V] AS
  
    
   
--select * FROm [cli].[CONOPS_CLI_TP_DELTA_C_V]    
    
CREATE VIEW [cli].[CONOPS_CLI_TP_DELTA_C_V]     
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
FROM [cli].[CONOPS_CLI_TP_DELTA_C_AVG_V]),    
    
    
STAT AS (    
select shiftid,eqmt,reasonidx,reasons,[status] as eqmtcurrstatus,    
ROW_NUMBER() OVER (PARTITION BY shiftid,eqmt ORDER BY startdatetime DESC) num    
from [cli].[asset_efficiency] WITH (NOLOCK)    
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
WHERE site_code = 'CLI')    
    
SELECT     
pop.shiftflag,    
pop.siteflag,    
pop.shiftid,    
dc.truck,    
pop.eqmttype,    
UPPER(pop.Operator) as toper,    
pop.OperatorImageURL,    
pop.OperatorID,    
pop.Payload AS AVG_Payload,    
pop.PayloadTarget AS AVG_PayloadTarget,    
dc.deltac,    
pop.DeltaCTarget AS Delta_c_target,    
dc.idletime,    
pop.idletimetarget,    
dc.spottime,    
pop.SpottingTarget AS spottarget,    
dc.loadtime,    
pop.LoadingTarget AS loadtarget,    
dc.DumpingTime,    
pop.dumpingtarget,    
dc.EFH,    
pop.EFHtarget,    
dc.DumpingAtStockpile,    
pop.DumpsAtStockpileTarget AS dumpingatStockpileTarget,    
dc.DumpingAtCrusher,    
pop.DumpsAtCrusherTarget AS dumpingAtCrusherTarget,    
dc.LoadedTravel,    
pop.LoadedTravelTarget,    
dc.EmptyTravel,    
pop.EmptyTravelTarget,    
pop.AvgUseOfAvailibility AS useOfAvailability,    
pop.AvgUseOfAvailibilityTarget AS useOfAvailabilityTarget,    
pop.TotalMaterialDelivered,    
pop.TotalMaterialDeliveredTarget,    
pop.[Location] AS [destination],    
pit.Pushback AS Pit,    
stat.reasonidx,    
stat.reasons,    
stat.eqmtcurrstatus    
FROM DELTAC dc    
LEFT JOIN [cli].[CONOPS_CLI_TRUCK_POPUP] pop WITH (NOLOCK) ON dc.shiftindex = pop.shiftindex AND dc.truck = pop.TruckID    
LEFT JOIN STAT stat ON pop.shiftid = stat.shiftid AND stat.eqmt = dc.truck AND stat.num = 1    
LEFT JOIN PIT pit ON pit.shiftindex = dc.shiftindex AND pit.TRUCK = dc.truck AND pit.row_num = 1    
    
WHERE pop.shiftflag is not null    
    
    
    
    
    
    
    
  
