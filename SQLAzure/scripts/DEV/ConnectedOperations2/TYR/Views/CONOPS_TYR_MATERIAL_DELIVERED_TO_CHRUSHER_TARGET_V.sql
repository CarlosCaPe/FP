CREATE VIEW [TYR].[CONOPS_TYR_MATERIAL_DELIVERED_TO_CHRUSHER_TARGET_V] AS



--select * from [tyr].[CONOPS_TYR_MATERIAL_DELIVERED_TO_CHRUSHER_TARGET_V] WITH (NOLOCK)

CREATE VIEW [tyr].[CONOPS_TYR_MATERIAL_DELIVERED_TO_CHRUSHER_TARGET_V] 
AS

WITH TGT AS (
SELECT 
shiftflag,
destination,
ShovelShiftTarget,
shoveltarget
FROM [tyr].[CONOPS_TYR_SHOVEL_SHIFT_TARGET_V]
WHERE destination = 'Crusher'),

FinalTarget AS (
SELECT
shiftflag,
ROUND(SUM(shoveltarget)/1000.0,1) AS MillOreTarget,
ROUND(SUM(ShovelShiftTarget)/1000.0,1) AS MillOreShiftTarget
FROM TGT
--WHERE shiftflag = 'curr'
GROUP BY shiftflag,destination)


SELECT
shiftflag,
'Crusher' [Location],
SUM(MillOreTarget) AS MillOreTarget,
SUM(MillOreShiftTarget) AS MillOreShiftTarget
FROM FinalTarget
GROUP BY Shiftflag

	


