CREATE VIEW [cli].[CONOPS_CLI_MATERIAL_DELIVERED_TO_CHRUSHER_TARGET_V] AS




--select * from [cli].[CONOPS_CLI_MATERIAL_DELIVERED_TO_CHRUSHER_TARGET_V] WITH (NOLOCK)
CREATE VIEW [cli].[CONOPS_CLI_MATERIAL_DELIVERED_TO_CHRUSHER_TARGET_V] 
AS
	SELECT case when right(shiftid,1) = 1 
		THEN concat(right(replace(cast(LEFT(shiftid,CHARINDEX('-', shiftid) - 1) as date),'-',''),6),'001')
		ELSE concat(right(replace(cast(LEFT(shiftid,CHARINDEX('-', shiftid) - 1) as date),'-',''),6),'002')
		END AS shiftid,
			   [siteflag],
			   'Crusher 1' [Location], 
			   TotalTonstoCrusher [Target]
		FROM [cli].[plan_values] WITH (NOLOCK)

