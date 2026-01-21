CREATE VIEW [bag].[zzz_CONOPS_BAG_DELTA_J_V] AS





--select * from [bag].[CONOPS_BAG_DELTA_J_V] 
CREATE VIEW [bag].[zzz_CONOPS_BAG_DELTA_J_V] 
AS

WITH Tons AS (
SELECT 
shiftflag,
siteflag,
shiftid,
shiftindex,
shovelid,
TotalMaterialMined,
dateadd(hour,shiftseq,ShiftStartDateTime) as TimeinHour
FROM [bag].[CONOPS_BAG_HOURLY_TONS_V]),

TonsTarget AS (
SELECT 
Formatshiftid,
shovel,
sum(shovelshifttarget) as shovelshifttarget
from [bag].[CONOPS_BAG_SHOVEL_TARGET_V] WITH (NOLOCK)
group by Formatshiftid,shovel),

EFH AS (
SELECT 
shiftindex,
excav as shovelid,
EFH,
EFHtarget,
CAST(CONCAT(LEFT(UTC_CREATED_DATE,11),' ',CONCAT(CONVERT(VARCHAR(5),UTC_CREATED_DATE,108),':00.000')) AS DATETIME) AS UTC_CREATED_DATE
FROM dbo.Shovel_Equivalent_Flat_Haul
CROSS JOIN (
SELECT TOP 1
EFH as EFHtarget
FROM [bag].[plan_values_prod_sum] WITH (NOLOCK)
ORDER BY EffectiveDate DESC) b
WHERE siteflag = 'BAG')


SELECT
shiftflag,
siteflag,
TimeinHour,
a.shovelid,
TotalMaterialMined,
shovelshifttarget,
EFH,
EFHTarget,
CASE WHEN EFHtarget IS NULL OR shovelshifttarget = 0 THEN 0 ELSE
ROUND(((TotalMaterialMined/shovelshifttarget) * (EFH/EFHtarget)) * 100,0) END AS DeltaJ
FROM Tons a
LEFT JOIN TonsTarget b ON a.shiftid = b.FORMATSHIFTID AND a.shovelid = b.shovel
INNER JOIN EFH c ON a.shiftindex = c.shiftindex AND a.shovelid = c.shovelid AND a.TimeinHour = c.UTC_CREATED_DATE


