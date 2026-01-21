CREATE VIEW [CLI].[CONOPS_CLI_EOS_TOTAL_MATERIAL_V] AS




--select * from [cli].[CONOPS_CLI_OVERVIEW_V]
CREATE VIEW [cli].[CONOPS_CLI_EOS_TOTAL_MATERIAL_V]
AS


WITH TONS AS (
SELECT
	a.siteflag,
	a.shiftflag,
	SUM(b.TotalMaterialMined) TotalMaterialMined,
	SUM(b.TotalMaterialMoved) TotalMaterialMoved
FROM [CLI].[CONOPS_CLI_SHIFT_INFO_V] a
LEFT JOIN [CLI].[CONOPS_CLI_SHIFT_OVERVIEW_V] b
	ON a.shiftid = b.shiftid
GROUP BY a.siteflag, a.shiftflag
),

Crusher AS (
SELECT
	shiftflag,
	SUM(ISNULL(LeachActual, 0) + ISNULL(MillOreActual, 0))  * 1000 AS TotalMaterialDeliveredToCrusher
FROM [CLI].[CONOPS_CLI_MATERIAL_DELIVERED_TO_CHRUSHER_V]
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





