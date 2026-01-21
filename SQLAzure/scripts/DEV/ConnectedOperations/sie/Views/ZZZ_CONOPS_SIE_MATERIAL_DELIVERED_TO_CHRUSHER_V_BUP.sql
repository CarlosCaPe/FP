CREATE VIEW [sie].[ZZZ_CONOPS_SIE_MATERIAL_DELIVERED_TO_CHRUSHER_V_BUP] AS





--select * from [sie].[CONOPS_SIE_MATERIAL_DELIVERED_TO_CHRUSHER_V]

CREATE VIEW [sie].[CONOPS_SIE_MATERIAL_DELIVERED_TO_CHRUSHER_V] 
AS

WITH CTE AS(
	SELECT  shiftid,
			siteflag,
			CASE WHEN [loc] IN ('CR13909O', 'A-SIDE', 'B-SIDE') THEN 'Crusher' 
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
			FROM [sie].SHIFT_DUMP_V dumps  WITH (NOLOCK)
			LEFT JOIN [sie].Enum enums WITH (NOLOCK) on enums.Id=dumps.FieldLoad 
			LEFT JOIN [sie].shift_loc loc WITH (NOLOCK) ON loc.Id = dumps.FieldLoc 
			WHERE enums.Idx NOT IN (26,27,28,29,30)
				  AND (loc.FieldId IN ('CR13909O', 'A-SIDE', 'B-SIDE'))
		) AS Consolidated 
)
/*
CrLoc AS (
	SELECT 'Crusher 2' CrusherLoc
	UNION ALL
	SELECT 'Small Crusher' CrusherLoc
)*/

SELECT a.shiftid,
	   a.shiftflag,
       a.siteflag,
	   CrusherLoc,
	   SUM(COALESCE(TotalTons, 0)) AS MillOre,
	   0 AS CrusherLeach,
	   COUNT(TotalTons) AS TotalNrDumps
FROM [sie].[CONOPS_SIE_SHIFT_INFO_V] a
LEFT JOIN CTE b ON a.shiftid = b.shiftid
GROUP BY a.shiftid,CrusherLoc,a.siteflag,a.shiftflag

