CREATE VIEW [mor].[zzz_CONOPS_MOR_DELTA_C_DETAIL_V] AS





--select * from [mor].[CONOPS_MOR_DELTA_C_DETAIL_V] 
CREATE VIEW [mor].[zzz_CONOPS_MOR_DELTA_C_DETAIL_V] 
AS

WITH DeltaC AS (
SELECT 
shiftindex,
avg(delta_c) AS deltac,
avg(idletime) AS idletime,
avg(spottime) AS spotting,
avg(loadtime) AS loading,
avg(DumpingTime) AS Dumping,
avg(ET_DELTA) AS EmptyTravel,
avg(LT_DELTA) AS LoadedTravel
FROM dbo.delta_c WITH (NOLOCK)
WHERE site_code = 'MOR'
GROUP BY shiftindex),

Other AS (
SELECT 
shiftindex,
CASE WHEN unit = 'Stockpile' THEN COALESCE(avg([dumpdelta]), 0) END AS DumpingAtStockpile,
CASE WHEN unit = 'Crusher' THEN COALESCE(avg([dumpdelta]), 0) END AS DumpingAtCrusher
FROM dbo.delta_c WITH (NOLOCK)
WHERE site_code = 'MOR'
GROUP BY shiftindex, unit),

Targets AS (
SELECT TOP 1 
DeltaC as DeltaCTarget,
spoting as SpottingTarget, 
loading as LoadingTarget,
'1.1' idletimetarget,
(DeltaCDumpCr + DeltaCDumpStk) as dumpingtarget,
DeltaCDumpCr AS DumpingAtCrusherTarget,
DeltaCDumpStk AS DumpingatStockpileTarget,
deltacloadedtravel as loadedtraveltarget,
deltacemptytravel as emptytraveltarget
FROM [mor].[plan_values_prod_sum] (nolock)
ORDER BY DateEffective DESC)

SELECT
a.shiftflag,
a.siteflag,
AVG(DeltaC) DeltaC,
DeltaCTarget,
AVG(IdleTime) IdleTime,
idletimetarget,
AVG(Spotting) Spotting,
SpottingTarget,
AVG(Loading) Loading,
LoadingTarget,
AVG(Dumping) Dumping,
DumpingTarget,
AVG(EmptyTravel) EmptyTravel,
emptytraveltarget,
AVG(LoadedTravel) LoadedTravel,
loadedtraveltarget,
AVG(DumpingAtStockpile) DumpingAtStockpile,
DumpingAtStockpileTarget,
AVG(DumpingAtCrusher) DumpingAtCrusher,
DumpingAtCrusherTarget
FROM [mor].CONOPS_MOR_SHIFT_INFO_V a
LEFT JOIN DeltaC b ON a.SHIFTINDEX = b.SHIFTINDEX
LEFT JOIN Other c ON a.SHIFTINDEX = c.SHIFTINDEX
CROSS JOIN Targets d

GROUP BY a.shiftflag,a.siteflag,DeltaCTarget,idletimetarget,SpottingTarget,LoadingTarget,DumpingTarget,
emptytraveltarget,loadedtraveltarget,DumpingAtStockpileTarget,DumpingAtCrusherTarget



