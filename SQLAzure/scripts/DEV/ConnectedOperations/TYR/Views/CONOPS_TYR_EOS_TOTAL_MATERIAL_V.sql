CREATE VIEW [TYR].[CONOPS_TYR_EOS_TOTAL_MATERIAL_V] AS





--select * from [tyr].[CONOPS_TYR_OVERVIEW_V]
CREATE VIEW [tyr].[CONOPS_TYR_EOS_TOTAL_MATERIAL_V]
AS


WITH TONS AS (
SELECT
	a.siteflag,
	a.shiftflag,
	SUM(b.TotalMaterialMined) TotalMaterialMined,
	SUM(b.TotalMaterialMoved) TotalMaterialMoved
FROM [TYR].[CONOPS_TYR_SHIFT_INFO_V] a
LEFT JOIN [TYR].[CONOPS_TYR_SHIFT_OVERVIEW_V] b
	ON a.shiftid = b.shiftid
GROUP BY a.siteflag, a.shiftflag
),

Crusher AS (
SELECT
	shiftflag,
	SUM(ISNULL(LeachActual, 0) + ISNULL(MillOreActual, 0))  * 1000 AS TotalMaterialDeliveredToCrusher
FROM [TYR].[CONOPS_TYR_MATERIAL_DELIVERED_TO_CHRUSHER_V]
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





