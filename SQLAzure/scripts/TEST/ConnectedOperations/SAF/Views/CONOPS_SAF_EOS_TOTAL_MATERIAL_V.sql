CREATE VIEW [SAF].[CONOPS_SAF_EOS_TOTAL_MATERIAL_V] AS





--select * from [saf].[CONOPS_SAF_OVERVIEW_V]
CREATE VIEW [saf].[CONOPS_SAF_EOS_TOTAL_MATERIAL_V]
AS


WITH TONS AS (
SELECT 
shiftid,
SUM(TotalMaterialMined) TotalMaterialMined,
SUM(TotalMineralsMined) TotalMaterialMoved
FROM [saf].[CONOPS_SAF_SHIFT_OVERVIEW_V]
GROUP BY shiftid),

Crusher AS (
SELECT
shiftflag,
(SUM(LeachActual) + SUM(MillOreActual)) * 1000 AS TotalMaterialDeliveredToCrusher
FROM [saf].[CONOPS_SAF_MATERIAL_DELIVERED_TO_CHRUSHER_V]
GROUP BY shiftflag)

SELECT 
a.siteflag,
a.shiftflag,
TotalMaterialMined,
TotalMaterialMoved,
ROUND(TotalMaterialDeliveredToCrusher,0) TotalMaterialDeliveredToCrusher
FROM [saf].[CONOPS_SAF_SHIFT_INFO_V] a
LEFT JOIN TONS b on b.shiftid = a.shiftid 
LEFT JOIN Crusher c on a.shiftflag = c.shiftflag 





