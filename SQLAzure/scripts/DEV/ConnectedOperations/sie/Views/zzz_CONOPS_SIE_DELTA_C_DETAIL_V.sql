CREATE VIEW [sie].[zzz_CONOPS_SIE_DELTA_C_DETAIL_V] AS




--select * from [sie].[CONOPS_SIE_DELTA_C_DETAIL_V] 
CREATE VIEW [sie].[zzz_CONOPS_SIE_DELTA_C_DETAIL_V] 
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
WHERE site_code = 'SIE'
GROUP BY shiftindex),

Other AS (
SELECT 
shiftindex,
CASE WHEN unit = 'Stockpile' THEN COALESCE(avg([dumpdelta]), 0) END AS DumpingAtStockpile,
CASE WHEN unit = 'Crusher' THEN COALESCE(avg([dumpdelta]), 0) END AS DumpingAtCrusher
FROM dbo.delta_c WITH (NOLOCK)
WHERE site_code = 'SIE'
GROUP BY shiftindex, unit),

Targets AS (
SELECT TOP 1
DeltaC as DeltaCTarget,
'1.1' as SpottingTarget,
(dumpingatcrusher + dumpingatstockpile) AS  dumpingtarget,
dumpingatcrusher as DumpingatCrusherTarget,
dumpingatstockpile as dumpingatstockpileTarget,
idletime AS idletimetarget,
LOADEDTRAVEL as loadedtraveltarget, 
EMPTYTRAVEL as emptytraveltarget
FROM [sie].[plan_values_prod_sum] (nolock)
ORDER BY DateEffective DESC),

LoadTime AS (
select 
AVG (LoadTimeTarget) AS LoadingTarget
from (
SELECT TOP 1
S43LOADING,S44LOADING,S48LOADING,S45LOADING,L50LOADING,L98LOADING
FROM [sie].[plan_values_prod_sum] ORDER BY DateEffective DESC) shv
unpivot
(
  LoadTimeTarget
  for ShovelId in (S43LOADING,S44LOADING,S48LOADING,S45LOADING,L50LOADING,L98LOADING)
) unpiv
)

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
FROM [sie].CONOPS_SIE_SHIFT_INFO_V a
LEFT JOIN DeltaC b ON a.SHIFTINDEX = b.SHIFTINDEX
LEFT JOIN Other c ON a.SHIFTINDEX = c.SHIFTINDEX
CROSS JOIN Targets d
CROSS JOIN LoadTime e

GROUP BY a.shiftflag,a.siteflag,DeltaCTarget,idletimetarget,SpottingTarget,LoadingTarget,DumpingTarget,
emptytraveltarget,loadedtraveltarget,DumpingAtStockpileTarget,DumpingAtCrusherTarget



