CREATE VIEW [cer].[CONOPS_CER_SHOVEL_SHIFT_TARGET_V] AS


--select * from [cer].[CONOPS_CER_SHOVEL_SHIFT_TARGET_V] where shiftflag = 'curr'
CREATE VIEW [cer].[CONOPS_CER_SHOVEL_SHIFT_TARGET_V]
AS


WITH CTE AS (
SELECT 
shiftid,
shovel,
sum(shovelshifttarget) AS shovelshifttarget
FROM [cer].[CONOPS_CER_SHOVEL_TARGET_V]
GROUP BY shiftid, shovel)

SELECT
siteflag,
shiftflag,
a.shiftid,
shovel AS shovelid,
shovelshifttarget,
((SHIFTDURATION/3600.0) /12.0) AS ShiftCompleteHOur,
((SHIFTDURATION/3600.0) /12.0) * shovelshifttarget AS ShovelTarget
FROM [CER].[CONOPS_CER_SHIFT_INFO_V] a
LEFT JOIN CTE b ON a.shiftid = b.Shiftid


