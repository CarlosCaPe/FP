CREATE VIEW [saf].[zzz_CONOPS_SAF_DELTA_J_V] AS





--select * from [saf].[CONOPS_SAF_DELTA_J_V] 
CREATE VIEW [saf].[zzz_CONOPS_SAF_DELTA_J_V] 
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
FROM [saf].[CONOPS_SAF_HOURLY_TONS_V]),

TonsTarget AS (
SELECT 
shiftid,
shovel,
sum(shovelshifttarget) as shovelshifttarget
FROM [saf].[CONOPS_SAF_SHOVEL_TARGET_V]
group by shiftid,shovel),

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
EFHtarget
FROM [saf].[CONOPS_SAF_DELTA_C_TARGET_V]
ORDER BY shiftid DESC) b
WHERE a.siteflag = 'SAF')


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
LEFT JOIN TonsTarget b ON a.shiftid = b.shiftid AND a.shovelid = b.shovel
INNER JOIN EFH c ON a.shiftindex = c.shiftindex 
AND a.shovelid = c.shovelid AND a.TimeinHour = c.UTC_CREATED_DATE


