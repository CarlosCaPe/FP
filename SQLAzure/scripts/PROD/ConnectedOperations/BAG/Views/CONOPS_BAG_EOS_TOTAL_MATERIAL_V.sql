CREATE VIEW [BAG].[CONOPS_BAG_EOS_TOTAL_MATERIAL_V] AS





--select * from [bag].[CONOPS_BAG_OVERVIEW_V]
CREATE VIEW [bag].[CONOPS_BAG_EOS_TOTAL_MATERIAL_V]
AS


WITH TONS AS (
SELECT
	a.siteflag,
	a.shiftflag,
	SUM(b.TotalMaterialMined) TotalMaterialMined,
	SUM(b.TotalMaterialMoved) TotalMaterialMoved
FROM [BAG].[CONOPS_BAG_SHIFT_INFO_V] a
LEFT JOIN [BAG].[CONOPS_BAG_SHIFT_OVERVIEW_V] b
	ON a.shiftid = b.shiftid
GROUP BY a.siteflag, a.shiftflag
),

Crusher AS (
SELECT
	shiftflag,
	SUM(ISNULL(LeachActual, 0) + ISNULL(MillOreActual, 0))  * 1000 AS TotalMaterialDeliveredToCrusher
FROM [BAG].[CONOPS_BAG_MATERIAL_DELIVERED_TO_CHRUSHER_V]
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





