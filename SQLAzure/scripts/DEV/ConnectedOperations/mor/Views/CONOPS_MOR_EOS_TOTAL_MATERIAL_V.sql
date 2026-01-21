CREATE VIEW [mor].[CONOPS_MOR_EOS_TOTAL_MATERIAL_V] AS







--select * from [mor].[CONOPS_MOR_EOS_TOTAL_MATERIAL_V]
CREATE VIEW [mor].[CONOPS_MOR_EOS_TOTAL_MATERIAL_V]
AS


WITH TONS AS (
SELECT
	a.siteflag,
	a.shiftflag,
	SUM(b.TotalMaterialMined) TotalMaterialMined,
	SUM(b.TotalMineralsMined) TotalMaterialMoved
FROM [mor].[CONOPS_MOR_SHIFT_INFO_V] a
LEFT JOIN [mor].[CONOPS_MOR_SHIFT_OVERVIEW_V] b
	ON a.shiftid = b.shiftid
GROUP BY a.siteflag, a.shiftflag
),

Crusher AS (
SELECT
	shiftflag,
	SUM(ISNULL(LeachActual, 0) + ISNULL(MillOreActual, 0))  * 1000 AS TotalMaterialDeliveredToCrusher
FROM [mor].[CONOPS_MOR_MATERIAL_DELIVERED_TO_CHRUSHER_V]
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








