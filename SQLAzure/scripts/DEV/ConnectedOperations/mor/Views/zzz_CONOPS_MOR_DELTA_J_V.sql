CREATE VIEW [mor].[zzz_CONOPS_MOR_DELTA_J_V] AS





--select * from [mor].[CONOPS_MOR_DELTA_J_V] 
CREATE VIEW [mor].[zzz_CONOPS_MOR_DELTA_J_V] 
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
FROM [mor].[CONOPS_MOR_HOURLY_TONS_V]),

TonsTarget AS (
SELECT 
Formatshiftid,
shovel,
sum(tons) as shovelshifttarget
from [mor].[plan_values] WITH (NOLOCK)
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
EquivalentFlatHaul as EFHtarget
FROM [mor].[plan_values_prod_sum] WITH (NOLOCK)
ORDER BY DateEffective DESC) b
WHERE siteflag = 'MOR')


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
INNER JOIN EFH c ON a.shiftindex = c.shiftindex 
AND a.shovelid = c.shovelid AND a.TimeinHour = c.UTC_CREATED_DATE


