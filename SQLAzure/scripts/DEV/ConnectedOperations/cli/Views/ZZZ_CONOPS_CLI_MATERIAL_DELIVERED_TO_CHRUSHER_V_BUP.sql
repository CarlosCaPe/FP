CREATE VIEW [cli].[ZZZ_CONOPS_CLI_MATERIAL_DELIVERED_TO_CHRUSHER_V_BUP] AS





--select * from [cli].[CONOPS_CLI_MATERIAL_DELIVERED_TO_CHRUSHER_V]

CREATE VIEW [cli].[CONOPS_CLI_MATERIAL_DELIVERED_TO_CHRUSHER_V] 
AS

WITH CTE AS(
	SELECT  shiftid,
			siteflag,
			CASE WHEN [loc] IN ('CRUSHER 1') THEN 'Crusher 1' 
			ELSE  NULL END
			AS CrusherLoc,
			[LfTons] AS TotalTons
	FROM 
		(
			SELECT  dumps.shiftid,
					dumps.siteflag,
					enums.Idx as [Load], 
					loc.FieldId as loc,
					dumps.FieldLsizetons AS [LfTons]
			FROM [cli].SHIFT_DUMP dumps  WITH (NOLOCK)
			LEFT JOIN [cli].Enum enums WITH (NOLOCK) on enums.Id=dumps.FieldLoad 
			LEFT JOIN [cli].shift_loc loc WITH (NOLOCK) ON loc.Id = dumps.FieldLoc 
			WHERE enums.Idx NOT IN (26,27,28,29,30)
			AND (loc.FieldId IN ('CRUSHER 1'))
		) AS Consolidated 
)
/*
CrLoc AS (
	SELECT 'Crusher 2' CrusherLoc
	UNION ALL
	SELECT 'Small Crusher' CrusherLoc
)*/

SELECT a.shiftid,
       a.siteflag,
	   a.shiftflag,
	   CrusherLoc,
	   SUM(COALESCE(TotalTons, 0)) AS MillOre,
	   0 AS CrusherLeach,
	   COUNT(TotalTons) AS TotalNrDumps
FROM [cli].[CONOPS_CLI_SHIFT_INFO_V] a
LEFT JOIN CTE b ON a.shiftid = b.shiftid 
GROUP BY a.shiftid,CrusherLoc,a.siteflag,a.shiftflag

