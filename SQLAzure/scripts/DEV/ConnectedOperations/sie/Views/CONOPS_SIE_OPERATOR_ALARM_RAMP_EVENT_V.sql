CREATE VIEW [sie].[CONOPS_SIE_OPERATOR_ALARM_RAMP_EVENT_V] AS



-- SELECT * FROM [SIE].[CONOPS_SIE_OPERATOR_ALARM_RAMP_EVENT_V] WITH (NOLOCK) WHERE Shiftflag = 'PREV'
CREATE VIEW [sie].[CONOPS_SIE_OPERATOR_ALARM_RAMP_EVENT_V] 
AS

	SELECT [shiftflag]
		  ,[siteflag]
		  ,[OPERATORID]
		  ,[DRILL_ID] AS [EQMT_ID]
		  ,'RAMP EVENT' AS [ALERT_TYPE]
		  ,'RAMP EVENT' AS [ALERT_NAME]
		  ,[alarm_name] AS [ALERT_DESCRIPTION]
		  ,[alarm_start_time] AS [GeneratedDate]
	FROM [SIE].[CONOPS_SIE_OPERATOR_DRILL_RAMP_EVENT_V] WITH (NOLOCK)
	UNION ALL
	SELECT [shiftflag]
		  ,[siteflag]
		  ,[OPERATORID]
		  ,[ShovelId] AS [EQMT_ID]
		  ,'RAMP EVENT' AS [ALERT_TYPE]
		  ,'RAMP EVENT' AS [ALERT_NAME]
		  ,[alarm_name] AS [ALERT_DESCRIPTION]
		  ,[alarm_start_time] AS [GeneratedDate]
	FROM [SIE].[CONOPS_SIE_OPERATOR_SHOVEL_RAMP_EVENT_V] WITH (NOLOCK)
	UNION ALL
	SELECT [shiftflag]
		  ,[siteflag]
		  ,[OPERATORID]
		  ,TruckID AS [EQMT_ID]
		  ,'RAMP EVENT' AS [ALERT_TYPE]
		  ,'RAMP EVENT' AS [ALERT_NAME]
		  ,[alarm_name] AS [ALERT_DESCRIPTION]
		  ,[alarm_start_time] AS [GeneratedDate]
	FROM [SIE].[CONOPS_SIE_OPERATOR_TRUCK_RAMP_EVENT_V] WITH (NOLOCK)

