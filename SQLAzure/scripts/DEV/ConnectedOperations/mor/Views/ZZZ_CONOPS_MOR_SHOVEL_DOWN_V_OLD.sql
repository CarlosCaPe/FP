CREATE VIEW [mor].[ZZZ_CONOPS_MOR_SHOVEL_DOWN_V_OLD] AS





-- SELECT * FROM [mor].[CONOPS_MOR_SHOVEL_DOWN_V] WITH (NOLOCK)
CREATE VIEW [mor].[CONOPS_MOR_SHOVEL_DOWN_V_OLD] 
AS

	SELECT [shift].shiftflag,
		   [shift].[siteflag],
		   [s].[ShovelID],
		   COALESCE([sd].Actualvalue, 0) [Actualvalue],
		   COALESCE([sd].ShiftTarget, 0) ShiftTarget,
		   [Operator],
		   OperatorImageURL
	FROM [dbo].[SHIFT_INFO_V] [shift] WITH (NOLOCK)
	LEFT JOIN (
		SELECT [s].SHIFTINDEX,
			   [s].FieldId AS [ShovelID],
			   [enumStats].Idx AS [StatusCode],
			   COALESCE([w].FieldName, 'NONE') AS [Operator],
			   CASE WHEN [s].FieldCuroper IS NULL OR [s].FieldCuroper = -1 THEN NULL
			   ELSE concat('https://images.services.fmi.com/publishedimages/',
						   FORMAT([s].FieldCuroper, '0000000000'),'.jpg') END as OperatorImageURL
		FROM [mor].[pit_excav_c] [s] WITH (NOLOCK)
		LEFT JOIN [mor].[enum] [enumStats] WITH (NOLOCK)
			ON [s].FieldStatus = [enumStats].Id
		LEFT JOIN [mor].[pit_worker] [w] WITH (NOLOCK)
			ON [w].Id = [s].FieldCuroper
		WHERE [enumStats].Idx = 1
	) [s]
	ON [shift].shiftindex = [s].SHIFTINDEX
	LEFT JOIN [dbo].[CONOPS_LH_OVERVIEW_BY_SHOVEL_V] [sd] WITH (NOLOCK)
	ON [sd].shiftflag = [shift].shiftflag AND [sd].siteflag = 'MOR'
	   AND [sd].Shovelid = [s].ShovelID

	WHERE [shift].siteflag = 'MOR'

