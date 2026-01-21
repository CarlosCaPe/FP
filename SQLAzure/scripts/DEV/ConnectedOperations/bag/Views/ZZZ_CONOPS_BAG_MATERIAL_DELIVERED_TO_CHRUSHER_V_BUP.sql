CREATE VIEW [bag].[ZZZ_CONOPS_BAG_MATERIAL_DELIVERED_TO_CHRUSHER_V_BUP] AS




--select * from [bag].[CONOPS_BAG_MATERIAL_DELIVERED_TO_CHRUSHER_V]

CREATE VIEW [bag].[CONOPS_BAG_MATERIAL_DELIVERED_TO_CHRUSHER_V] 
AS

WITH CTE AS(
	SELECT  siteflag,
			shiftid,
			CASE WHEN [loc] IN ('Crusher 2') THEN 'Crusher 2' 
				 WHEN [loc] IN ('SMALL CR_T') THEN 'Small Crusher'
			ELSE  NULL END
			AS CrusherLoc,
			[LfTons] AS TotalTons
	FROM 
		(
			SELECT  dumps.siteflag,
					dumps.shiftid,
					enums.Idx as [Load], 
					loc.FieldId as loc,
					dumps.FieldLsizetons AS [LfTons]
			FROM [bag].SHIFT_DUMP dumps  WITH (NOLOCK)
			LEFT JOIN bag.Enum enums WITH (NOLOCK) on enums.Id=dumps.FieldLoad 
			LEFT JOIN bag.shift_loc loc WITH (NOLOCK) ON loc.Id = dumps.FieldLoc 
			WHERE enums.Idx NOT IN (26,27,28,29,30)
				  AND (loc.FieldId in ('Crusher 2')
				  OR loc.FieldId LIKE 'SMALL CR%')
		) AS Consolidated 
),

CrLoc AS (
	SELECT 'Crusher 2' CrusherLoc
	UNION ALL
	SELECT 'Small Crusher' CrusherLoc
),

Deliver AS (
SELECT
a.siteflag,
a.shiftflag,
a.shiftid,
b.CrusherLoc,
b.TotalTons
FROM [bag].[CONOPS_BAG_SHIFT_INFO_V] a
LEFT JOIN CTE b ON a.shiftid = b.SHIFTID)

SELECT dv.shiftflag,
	   dv.shiftid,
       dv.siteflag,
	   loc.CrusherLoc,
	   SUM(COALESCE(TotalTons, 0)) AS MillOre,
	   0 AS CrusherLeach,
	   COUNT(TotalTons) AS TotalNrDumps
FROM CrLoc loc
LEFT JOIN Deliver dv 
ON loc.CrusherLoc = dv.CrusherLoc
GROUP BY dv.shiftid, loc.CrusherLoc,dv.siteflag,dv.shiftflag


