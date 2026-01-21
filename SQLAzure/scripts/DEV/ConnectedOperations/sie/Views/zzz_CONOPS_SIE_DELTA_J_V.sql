CREATE VIEW [sie].[zzz_CONOPS_SIE_DELTA_J_V] AS





--select * from [sie].[CONOPS_SIE_DELTA_J_V] 
CREATE VIEW [sie].[zzz_CONOPS_SIE_DELTA_J_V] 
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
FROM [sie].[CONOPS_SIE_HOURLY_TONS_V]),

TonsTarget AS (
SELECT 
shiftflag,
shovelId,
sum(shovelshifttarget) as shovelshifttarget
from [sie].[CONOPS_SIE_SHOVEL_SHIFT_TARGET_V] (nolock)
group by shiftflag,shovelId),

EFH AS (
SELECT 
shiftindex,
excav as shovelid,
EFH,
EFHtarget,
CAST(CONCAT(LEFT(UTC_CREATED_DATE,11),' ',CONCAT(CONVERT(VARCHAR(5),UTC_CREATED_DATE,108),':00.000')) AS DATETIME) AS UTC_CREATED_DATE
FROM dbo.Shovel_Equivalent_Flat_Haul a
CROSS JOIN (
SELECT TOP 1
EquivalentFlatHaul AS EFHtarget
FROM [sie].[plan_values_prod_sum] WITH (NOLOCK)
ORDER BY DateEffective DESC) b
WHERE a.siteflag = 'SIE')


SELECT
a.shiftflag,
siteflag,
TimeinHour,
a.shovelid,
TotalMaterialMined,
shovelshifttarget,
EFH,
EFHTarget,
CASE WHEN EFHtarget IS NULL THEN 0 ELSE
ROUND(((TotalMaterialMined/shovelshifttarget) * (EFH/EFHtarget)) * 100,0) END AS DeltaJ
FROM Tons a
LEFT JOIN TonsTarget b ON a.shiftflag = b.shiftflag AND a.shovelid = b.shovelid
INNER JOIN EFH c ON a.shiftindex = c.shiftindex 
AND a.shovelid = c.shovelid AND a.TimeinHour = c.UTC_CREATED_DATE


