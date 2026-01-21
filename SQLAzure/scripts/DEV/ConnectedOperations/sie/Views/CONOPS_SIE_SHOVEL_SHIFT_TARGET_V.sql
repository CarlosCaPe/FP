CREATE VIEW [sie].[CONOPS_SIE_SHOVEL_SHIFT_TARGET_V] AS





--SELECT * FROM [sie].[CONOPS_SIE_SHOVEL_SHIFT_TARGET_V]
CREATE VIEW [sie].[CONOPS_SIE_SHOVEL_SHIFT_TARGET_V]
AS

WITH TGT AS (
SELECT
shiftid as orig_shiftid,
CASE WHEN CONVERT(CHAR(5), shiftid, 108) = '06:15' 
THEN CONCAT(RIGHT(REPLACE(CAST(shiftid AS DATE),'-',''),6),'001')
ELSE CONCAT(RIGHT(REPLACE(CAST(shiftid AS DATE),'-',''),6),'002')
END AS shiftid, 
ShovelName as ShovelID,
destination,
Mass_Tons AS ShovelShiftTarget,
ROW_NUMBER() OVER (PARTITION BY shiftid,ShovelName,destination ORDER BY UTC_CREATED_DATE DESC) num
FROM [SIE].PLAN_VALUES)

SELECT
a.siteflag,
a.shiftflag,
a.shiftid,
b.ShovelID,
destination,
ROUND(SUM(b.ShovelShiftTarget),1) ShovelShiftTarget,
ROUND(((a.shiftduration/3600.0) / 12.0) * SUM(ShovelShiftTarget),1) AS ShovelTarget
FROM [SIE].[CONOPS_SIE_SHIFT_INFO_V] a
LEFT JOIN TGT b on a.shiftid = b.shiftid AND b.num = 1
GROUP BY
a.siteflag,
a.shiftflag,
a.shiftid,
b.ShovelID,
destination,
a.shiftduration



