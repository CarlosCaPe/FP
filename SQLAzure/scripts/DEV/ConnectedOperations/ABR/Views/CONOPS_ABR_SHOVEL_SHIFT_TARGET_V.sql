CREATE VIEW [ABR].[CONOPS_ABR_SHOVEL_SHIFT_TARGET_V] AS



--SELECT * FROM [abr].[CONOPS_ABR_SHOVEL_SHIFT_TARGET_V]
CREATE VIEW [ABR].[CONOPS_ABR_SHOVEL_SHIFT_TARGET_V]
AS

WITH TGT AS (
SELECT
FormatShiftId AS shiftid, 
Pala as ShovelID,
Destino as Destination,
Tons AS ShovelShiftTarget
FROM [abr].PLAN_VALUES WITH (NOLOCK))

SELECT
a.siteflag,
a.shiftflag,
a.shiftid,
b.ShovelID,
destination,
ROUND(SUM(b.ShovelShiftTarget),1) ShovelShiftTarget,
ROUND(((a.shiftduration/3600.0) / 12.0) * SUM(ShovelShiftTarget),1) AS ShovelTarget
FROM [abr].[CONOPS_ABR_SHIFT_INFO_V] a
LEFT JOIN TGT b on a.shiftid = b.shiftid 
GROUP BY
a.siteflag,
a.shiftflag,
a.shiftid,
b.ShovelID,
destination,
a.shiftduration



