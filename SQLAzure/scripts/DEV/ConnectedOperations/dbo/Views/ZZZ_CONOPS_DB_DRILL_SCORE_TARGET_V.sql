CREATE VIEW [dbo].[ZZZ_CONOPS_DB_DRILL_SCORE_TARGET_V] AS



--SELECT * FROM [dbo].[CONOPS_DB_DRILL_SCORE_TARGET_V] where shiftflag = 'curr' 
CREATE VIEW [dbo].[CONOPS_DB_DRILL_SCORE_TARGET_V]
AS

	SELECT [shift].shiftflag,
	       [shift].[siteflag],
		   [DRILLAVAILABILITY],
		   [DRILLASSETEFFICIENCY],
		   [DRILLUTILIZATION],
		   [TARGETFEETDRILLED],
		   [TARGETHOLESDRILLED]
	FROM [dbo].[SHIFT_INFO_V] [shift] WITH (NOLOCK)
	LEFT JOIN (
		SELECT [ShiftId],
			   [siteflag],
			   [DRILLAVAILABILITY],
			   [DRILLASSETEFFICIENCY],
			   [DRILLUTILIZATION],
			   [TARGETFEETDRILLED],
			   [TARGETHOLESDRILLED]
		FROM [bag].[CONOPS_BAG_DB_DRILL_SCORE_TARGET_V]
	) [t] ON LEFT([shift].shiftid, 4) = [t].ShiftId AND [shift].siteflag = [t].siteflag
	WHERE [shift].siteflag = 'BAG'

	UNION ALL

	SELECT [shift].shiftflag,
	       [shift].[siteflag],
		   [DRILLAVAILABILITY],
		   [DRILLASSETEFFICIENCY],
		   [DRILLUTILIZATION],
		   [TARGETFEETDRILLED],
		   [TARGETHOLESDRILLED]
	FROM [dbo].[SHIFT_INFO_V] [shift] WITH (NOLOCK)
	LEFT JOIN (
		SELECT [ShiftId],
			   [siteflag],
			   [DRILLAVAILABILITY],
			   [DRILLASSETEFFICIENCY],
			   [DRILLUTILIZATION],
			   [TARGETFEETDRILLED],
			   [TARGETHOLESDRILLED]
		FROM [saf].[CONOPS_SAF_DB_DRILL_SCORE_TARGET_V]
	) [t] ON [shift].shiftid = [t].ShiftId AND [shift].siteflag = [t].siteflag
	WHERE [shift].siteflag = 'SAF'

	UNION ALL

	SELECT [shift].shiftflag,
	       [shift].[siteflag],
		   [DRILLAVAILABILITY],
		   [DRILLASSETEFFICIENCY],
		   [DRILLUTILIZATION],
		   ISNULL([TARGETFEETDRILLED], 2372) AS [TARGETFEETDRILLED],
		   ISNULL([TARGETHOLESDRILLED], 153) AS [TARGETHOLESDRILLED]
	FROM [dbo].[SHIFT_INFO_V] [shift] WITH (NOLOCK)
	LEFT JOIN (
		SELECT [ShiftId],
			   [siteflag],
			   [DRILLAVAILABILITY],
			   [DRILLASSETEFFICIENCY],
			   [DRILLUTILIZATION],
			   [TARGETFEETDRILLED],
			   [TARGETHOLESDRILLED]
		FROM [cer].[CONOPS_CER_DB_DRILL_SCORE_TARGET_V]
	) [t] ON LEFT([shift].shiftid, 4) = [t].ShiftId AND [shift].siteflag = [t].siteflag
	WHERE [shift].siteflag = 'CER'

	UNION ALL

	SELECT [shift].shiftflag,
	       [shift].[siteflag],
		   [DRILLAVAILABILITY],
		   [DRILLASSETEFFICIENCY],
		   [DRILLUTILIZATION],
		   [TARGETFEETDRILLED] AS [TARGETFEETDRILLED],
		   [TARGETHOLESDRILLED] AS [TARGETHOLESDRILLED]
	FROM [dbo].[SHIFT_INFO_V] [shift] WITH (NOLOCK)
	LEFT JOIN (
		SELECT [ShiftId],
			   [siteflag],
			   [DRILLAVAILABILITY],
			   [DRILLASSETEFFICIENCY],
			   [DRILLUTILIZATION],
			   [TARGETFEETDRILLED],
			   [TARGETHOLESDRILLED]
		FROM [sie].[CONOPS_SIE_DB_DRILL_SCORE_TARGET_V]
	) [t] ON LEFT([shift].shiftid, 4) = [t].ShiftId AND [shift].siteflag = [t].siteflag
	WHERE [shift].siteflag = 'SIE'

	UNION ALL

	SELECT [shift].shiftflag,
	       [shift].[siteflag],
		   [DRILLAVAILABILITY],
		   [DRILLASSETEFFICIENCY],
		   [DRILLUTILIZATION],
		   [TARGETFEETDRILLED] AS [TARGETFEETDRILLED],
		   [TARGETHOLESDRILLED] AS [TARGETHOLESDRILLED]
	FROM [dbo].[SHIFT_INFO_V] [shift] WITH (NOLOCK)
	LEFT JOIN (
		SELECT [ShiftId],
			   [siteflag],
			   [DRILLAVAILABILITY],
			   [DRILLASSETEFFICIENCY],
			   [DRILLUTILIZATION],
			   [TARGETFEETDRILLED],
			   [TARGETHOLESDRILLED]
		FROM [cli].[CONOPS_CLI_DB_DRILL_SCORE_TARGET_V]
	) [t] ON [shift].shiftid = [t].ShiftId AND [shift].siteflag = [t].siteflag
	WHERE [shift].siteflag = 'CMX'

	UNION ALL

	SELECT [shift].shiftflag,
	       [shift].[siteflag],
		   [DRILLAVAILABILITY],
		   [DRILLASSETEFFICIENCY],
		   [DRILLUTILIZATION],
		   [TARGETFEETDRILLED] AS [TARGETFEETDRILLED],
		   [TARGETHOLESDRILLED] AS [TARGETHOLESDRILLED]
	FROM [dbo].[SHIFT_INFO_V] [shift] WITH (NOLOCK)
	LEFT JOIN (
		SELECT [ShiftId],
			   [siteflag],
			   [DRILLAVAILABILITY],
			   [DRILLASSETEFFICIENCY],
			   [DRILLUTILIZATION],
			   [TARGETFEETDRILLED],
			   [TARGETHOLESDRILLED]
		FROM [chi].[CONOPS_CHI_DB_DRILL_SCORE_TARGET_V]
	) [t] ON LEFT([shift].shiftid, 4) =