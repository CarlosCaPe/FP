CREATE VIEW [sie].[CONOPS_SIE_OPERATOR_DRILL_DELAY_V] AS


-- SELECT * FROM [sie].[CONOPS_SIE_OPERATOR_DRILL_DELAY_V] WITH (NOLOCK) WHERE Shiftflag = 'PREV'
CREATE VIEW [sie].[CONOPS_SIE_OPERATOR_DRILL_DELAY_V] 
AS

	WITH DelayStatus AS (
		SELECT SHIFTFLAG,
			   EQMT,
			   SUM(DURATION) AS DURATION,
			   REASONIDX,
			   REASON,
			   MAX(StartDateTime) AS AlertDateTime
		FROM [sie].[CONOPS_SIE_DB_EQMT_STATUS_V] (NOLOCK)
		WHERE siteflag = 'SIE'
			  AND [status] = 'DELAY'
			  AND reasonidx <> '439'
		GROUP BY SHIFTFLAG, EQMT, REASONIDX, REASON
	)

	SELECT [o].SHIFTFLAG,
		   [o].SITEFLAG,
		   [o].OperatorId,
		   [o].Drill_ID,
		   [o].PATTERN_NO,
		   [d].REASONIDX,
		   [d].REASON,
		   [d].AlertDateTime,
		   [d].DURATION
	FROM [sie].[CONOPS_SIE_OPERATOR_DRILL_LIST_V] [o] WITH (NOLOCK)
	LEFT JOIN DelayStatus [d]
	ON [o].Drill_ID = [d].EQMT
	   AND [o].SHIFTFLAG = [d].SHIFTFLAG
	WHERE [o].Drill_ID <> 'None' 
		  AND [d].REASONIDX IS NOT NULL

