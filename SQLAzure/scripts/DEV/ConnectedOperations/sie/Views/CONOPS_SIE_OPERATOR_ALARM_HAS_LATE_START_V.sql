CREATE VIEW [sie].[CONOPS_SIE_OPERATOR_ALARM_HAS_LATE_START_V] AS



-- SELECT * FROM [SIE].[CONOPS_SIE_OPERATOR_ALARM_HAS_LATE_START_V] WITH (NOLOCK) WHERE Shiftflag = 'PREV'
CREATE VIEW [sie].[CONOPS_SIE_OPERATOR_ALARM_HAS_LATE_START_V] 
AS

	SELECT [shiftflag]
		  ,[siteflag]
		  ,[OperatorId]
		  ,eqmtid
		  ,'LATE START' AS [ALERT_TYPE]
		  ,'LATE START' AS [ALERT_NAME]
		  ,NULL AS [ALERT_DESCRIPTION]
		  ,[FirstLoginDateTime] AS [GeneratedDate]
	FROM [SIE].[CONOPS_SIE_DRILL_OPERATOR_HAS_LATE_START_V] WITH (NOLOCK)
	UNION ALL
	SELECT [shiftflag]
		  ,[siteflag]
		  ,[OperatorId]
		  ,eqmtid
		  ,'LATE START' AS [ALERT_TYPE]
		  ,'LATE START' AS [ALERT_NAME]
		  ,NULL AS [ALERT_DESCRIPTION]
		  ,[FirstLoginDateTime] AS [GeneratedDate]
	FROM [SIE].[CONOPS_SIE_OPERATOR_HAS_LATE_START_V] WITH (NOLOCK)

