CREATE VIEW [dbo].[CONOPS_LH_SHOVEL_DOWN_V] AS








-- SELECT * FROM [dbo].[CONOPS_LH_SHOVEL_DOWN_V] WITH (NOLOCK)
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

	UNION ALL

	SELECT [s].shiftflag,
		   [s].siteflag,
		   [s].ShovelID,
		   Actualvalue,
		   ShiftTarget,
		   ShiftTarget - Actualvalue [OffTarget],
		   StatusCode
	FROM [saf].[CONOPS_SAF_SHOVEL_INFO_V] [s] WITH (NOLOCK)
	LEFT JOIN [dbo].[CONOPS_LH_OVERVIEW_BY_SHOVEL_V] [sd] WITH (NOLOCK)
	ON [sd].shiftflag = [s].shiftflag AND [sd].siteflag = [s].siteflag
	   AND [sd].Shovelid = [s].ShovelID
	WHERE StatusCode = 1
	AND [s].siteflag = 'SAF'

	UNION ALL

	SELECT [s].shiftflag,
		   [s].siteflag,
		   [s].ShovelID,
		   Actualvalue,
		   ShiftTarget,
		   ShiftTarget - Actualvalue [OffTarget],
		   StatusCode
	FROM [cer].[CONOPS_CER_SHOVEL_INFO_V] [s] WITH (NOLOCK)
	LEFT JOIN [dbo].[CONOPS_LH_OVERVIEW_BY_SHOVEL_V] [sd] WITH (NOLOCK)
	ON [sd].shiftflag = [s].shiftflag AND [sd].siteflag = [s].siteflag
	   AND [sd].Shovelid = [s].ShovelID
	WHERE StatusCode = 1
	      AND [s].siteflag = 'CER'


	UNION ALL

	SELECT [s].shiftflag,
		   [s].siteflag,
		   [s].ShovelID,
		   Actualvalue,
		   ShiftTarget,
		   ShiftTarget - Actualvalue [OffTarget],
		   StatusCode
	FROM [sie].[CONOPS_SIE_SHOVEL_INFO_V] [s] WITH (NOLOCK)
	LEFT JOIN [dbo].[CONOPS_LH_OVERVIEW_BY_SHOVEL_V] [sd] WITH (NOLOCK)
	ON [sd].shiftflag = [s].shiftflag AND [sd].siteflag = [s].siteflag
	   AND [sd].Shovelid = [s].ShovelID
	WHERE StatusCode = 1
	      AND [s].siteflag = 'SIE'

UNION ALL

	SELECT [s].shiftflag,
		   [s].siteflag,
		   [s].ShovelID,
		   Actualvalue,
		   ShiftTarget,
		   ShiftTarget - Actualvalue [OffTarget],
		   StatusCode
	FROM [cli].[CONOPS_CLI_SHOVEL_INFO_V] [s] WITH (NOLOCK)
	LEFT JOIN [dbo].[CONOPS_LH_OVERVIEW_BY_SHOVEL_V] [sd] WITH (NOLOCK)
	ON [sd].shiftflag = [s].shiftflag AND [sd].siteflag = [s].siteflag
	   AND [sd].Shovelid = [s].ShovelID
	WHERE StatusCode = 1
	AND [s].siteflag = 'CMX'

	UNION ALL

	SELECT [s].shiftflag,
		   [s].siteflag,
		   [s].ShovelID,
		   Actualvalue,
		   ShiftTarget,
		   ShiftTarget - Actualvalue [OffTarget],
		   StatusCode
	FROM [chi].[CONOPS_CHI_SHOVEL_INFO_V] [s] WITH (NOLOCK)
	LEFT JOIN [dbo].[CONOPS_LH_OVERVIEW_BY_SHOVEL_V] [sd] WITH (NOLOCK)
	ON [sd].shiftflag = [s].shiftflag AND [sd].siteflag = [s].siteflag
	   AND [sd].Shovelid = [s].ShovelID
	WHERE StatusCode = 1
	      AND [s].siteflag = 'CHI'

