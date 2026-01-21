CREATE VIEW [saf].[CONOPS_SAF_EOS_TOTAL_MATERIAL_V] AS





--select * from [saf].[CONOPS_SAF_OVERVIEW_V]
CREATE VIEW [saf].[CONOPS_SAF_EOS_TOTAL_MATERIAL_V]
AS


WITH TONS AS (
SELECT
	a.siteflag,
	a.shiftflag,
	SUM(b.TotalMaterialMined) TotalMaterialMined,
	SUM(b.TotalMineralsMined) TotalMaterialMoved
FROM [SAF].[CONOPS_SAF_SHIFT_INFO_V] a
LEFT JOIN [SAF].[CONOPS_SAF_SHIFT_OVERVIEW_V] b
	ON a.shiftid = b.shiftid
GROUP BY a.siteflag, a.shiftflag
),

Crusher AS (
SELECT
	shiftflag,
	SUM(ISNULL(LeachActual, 0) + ISNULL(MillOreActual, 0))  * 1000 AS TotalMaterialDeliveredToCrusher
FROM [SAF].[CONOPS_SAF_MATERIAL_DELIVERED_TO_CHRUSHER_V]
GROUP BY shiftflag
)

SELECT 
	a.siteflag,
	a.shiftflag,
	a.TotalMaterialMined,
	a.TotalMaterialMoved,
	ROUND(c.TotalMaterialDeliveredToCrusher,0) TotalMaterialDeliveredToCrusher
FROM TONS a
LEFT JOIN Crusher c
	ON a.shiftflag = c.shiftflag 





