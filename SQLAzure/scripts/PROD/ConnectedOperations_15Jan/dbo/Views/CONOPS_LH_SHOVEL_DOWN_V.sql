CREATE VIEW [dbo].[CONOPS_LH_SHOVEL_DOWN_V] AS


CREATE VIEW [dbo].[CONOPS_LH_SHOVEL_DOWN_V]
AS
	SELECT [s].shiftflag,
		   [s].siteflag,
		   [s].ShovelID,
		   Actualvalue,
		   ShiftTarget,
		   ShiftTarget - Actualvalue [OffTarget],
		   StatusCode
	FROM [mor].[CONOPS_MOR_SHOVEL_INFO_V] [s] WITH (NOLOCK)
	LEFT JOIN [dbo].[CONOPS_LH_OVERVIEW_BY_SHOVEL_V] [sd] WITH (NOLOCK)
	ON [sd].shiftflag = [s].shiftflag AND [sd].siteflag = [s].siteflag
	   AND [sd].Shovelid = [s].ShovelID
	WHERE StatusCode = 1
	      AND [s].siteflag = 'MOR'

	UNION ALL

	SELECT [s].shiftflag,
		   [s].siteflag,
		   [s].ShovelID,
		   Actualvalue,
		   ShiftTarget,
		   ShiftTarget - Actualvalue [OffTarget],
		   StatusCode
	FROM [bag].[CONOPS_BAG_SHOVEL_INFO_V] [s] WITH (NOLOCK)
	LEFT JOIN [dbo].[CONOPS_LH_OVERVIEW_BY_SHOVEL_V] [sd] WITH (NOLOCK)
	ON [sd].shiftflag = [s].shiftflag AND [sd].siteflag = [s].siteflag
	   AND [sd].Shovelid = [s].ShovelID
	WHERE StatusCode = 1
	AND [s].siteflag = 'BAG'


