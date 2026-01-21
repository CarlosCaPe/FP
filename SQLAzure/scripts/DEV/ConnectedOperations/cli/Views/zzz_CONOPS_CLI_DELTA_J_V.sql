CREATE VIEW [cli].[zzz_CONOPS_CLI_DELTA_J_V] AS





--select * from [cli].[CONOPS_CLI_DELTA_J_V] 
CREATE VIEW [cli].[zzz_CONOPS_CLI_DELTA_J_V] 
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
FROM [cli].[CONOPS_CLI_HOURLY_TONS_V]),

TonsTarget AS (
SELECT 
shiftid,
shovelId,
sum(shovelshifttarget) as shovelshifttarget
from [cli].[CONOPS_CLI_SHOVEL_SHIFT_TARGET_V] (nolock)
group by shiftid,shovelId),

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
EFH as EFHtarget
FROM [cli].[plan_values] WITH (NOLOCK)
ORDER BY shiftid DESC) b
WHERE a.siteflag = 'CLI')


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
LEFT JOIN TonsTarget b ON a.shiftid = b.shiftid AND a.shovelid = b.shovelid
INNER JOIN EFH c ON a.shiftindex = c.shiftindex 
AND a.shovelid = c.shovelid AND a.TimeinHour = c.UTC_CREATED_DATE


