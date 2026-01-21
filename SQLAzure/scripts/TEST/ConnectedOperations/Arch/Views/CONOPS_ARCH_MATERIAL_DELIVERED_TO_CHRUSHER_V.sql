CREATE VIEW [Arch].[CONOPS_ARCH_MATERIAL_DELIVERED_TO_CHRUSHER_V] AS


CREATE VIEW [Arch].[CONOPS_ARCH_MATERIAL_DELIVERED_TO_CHRUSHER_V]
AS

WITH CTE AS(
	SELECT  shiftid,
			CASE WHEN [loc] IN ('Crusher 2') THEN 'Crusher 2' 
				 WHEN [loc] IN ('SMALL CR_T') THEN 'Small Crusher'
			ELSE  NULL END
			AS CrusherLoc,
			[LfTons] AS TotalTons
	FROM 
		(
			SELECT  dumps.shiftid,
					enums.Idx as [Load], 
					loc.FieldId as loc,
					dumps.FieldLsizetons AS [LfTons]
			FROM [Arch].SHIFT_DUMP dumps  WITH (NOLOCK)
			LEFT JOIN ARCH.Enum enums WITH (NOLOCK) on enums.Id=dumps.FieldLoad 
			LEFT JOIN ARCH.shift_loc loc WITH (NOLOCK) ON loc.Id = dumps.FieldLoc 
			WHERE enums.Idx NOT IN (26,27,28,29,30)
				  AND (loc.FieldId in ('Crusher 2')
				  OR loc.FieldId LIKE 'SMALL CR%')
		) AS Consolidated 
),

CrLoc AS (
	SELECT 'Crusher 2' CrusherLoc
	UNION ALL
	SELECT 'Small Crusher' CrusherLoc
)

SELECT CTE.shiftid,
       '<SITECODE>' siteflag,
	   loc.CrusherLoc,
	   SUM(COALESCE(TotalTons, 0)) AS MillOre,
	   0 AS CrusherLeach,
	   COUNT(TotalTons) AS TotalNrDumps
FROM CrLoc loc
LEFT JOIN CTE 
ON loc.CrusherLoc = CTE.CrusherLoc
GROUP BY CTE.shiftid, loc.CrusherLoc 

