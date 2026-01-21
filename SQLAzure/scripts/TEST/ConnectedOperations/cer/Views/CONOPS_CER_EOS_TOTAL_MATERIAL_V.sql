CREATE VIEW [cer].[CONOPS_CER_EOS_TOTAL_MATERIAL_V] AS





--select * from [cer].[CONOPS_CER_OVERVIEW_V]
CREATE VIEW [cer].[CONOPS_CER_EOS_TOTAL_MATERIAL_V]
AS


WITH TONS AS (
SELECT 
shiftid,
SUM(TotalMaterialMined) TotalMaterialMined,
SUM(TotalMaterialMoved) TotalMaterialMoved
FROM [cer].[CONOPS_CER_SHIFT_OVERVIEW_V]
GROUP BY shiftid),

Crusher AS (
SELECT
shiftflag,
(SUM(LeachActual) + SUM(MillOreActual)) * 1000 AS TotalMaterialDeliveredToCrusher
FROM [cer].[CONOPS_CER_MATERIAL_DELIVERED_TO_CHRUSHER_V]
GROUP BY shiftflag)

SELECT 
a.siteflag,
a.shiftflag,
TotalMaterialMined,
TotalMaterialMoved,
ROUND(TotalMaterialDeliveredToCrusher,0) TotalMaterialDeliveredToCrusher
FROM [cer].[CONOPS_CER_SHIFT_INFO_V] a
LEFT JOIN TONS b on b.shiftid = a.shiftid 
LEFT JOIN Crusher c on a.shiftflag = c.shiftflag 





