CREATE VIEW [saf].[zzz_CONOPS_SAF_DELTA_C_DETAIL_V] AS




--select * from [saf].[CONOPS_SAF_DELTA_C_DETAIL_V] 
CREATE VIEW [saf].[zzz_CONOPS_SAF_DELTA_C_DETAIL_V] 
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
WHERE site_code = 'SAF'
GROUP BY shiftindex),

Other AS (
SELECT 
shiftindex,
CASE WHEN unit = 'Stockpile' THEN COALESCE(avg([dumpdelta]), 0) END AS DumpingAtStockpile,
CASE WHEN unit = 'Crusher' THEN COALESCE(avg([dumpdelta]), 0) END AS DumpingAtCrusher
FROM dbo.delta_c WITH (NOLOCK)
WHERE site_code = 'SAF'
GROUP BY shiftindex, unit),

Targets AS (
SELECT TOP 1 
Delta_c_target as DeltaCTarget,
spottarget as SpottingTarget, 
loadtarget as LoadingTarget,
idletimetarget as idletimetarget,
dumpingtarget,
DumpingAtCrusherTarget,
DumpingatStockpileTarget,
loadedtraveltarget,
emptytraveltarget
FROM [saf].[CONOPS_SAF_DELTA_C_TARGET_V]
ORDER BY shiftid DESC)

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
FROM [saf].CONOPS_SAF_SHIFT_INFO_V a
LEFT JOIN DeltaC b ON a.SHIFTINDEX = b.SHIFTINDEX
LEFT JOIN Other c ON a.SHIFTINDEX = c.SHIFTINDEX
CROSS JOIN Targets d

GROUP BY a.shiftflag,a.siteflag,DeltaCTarget,idletimetarget,SpottingTarget,LoadingTarget,DumpingTarget,
emptytraveltarget,loadedtraveltarget,DumpingAtStockpileTarget,DumpingAtCrusherTarget



