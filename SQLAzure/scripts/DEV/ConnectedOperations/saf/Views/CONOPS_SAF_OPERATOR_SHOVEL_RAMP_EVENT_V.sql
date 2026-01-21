CREATE VIEW [saf].[CONOPS_SAF_OPERATOR_SHOVEL_RAMP_EVENT_V] AS




-- SELECT * FROM [SAF].[CONOPS_SAF_OPERATOR_SHOVEL_RAMP_EVENT_V] WITH (NOLOCK) WHERE Shiftflag = 'PREV'
CREATE VIEW [SAF].[CONOPS_SAF_OPERATOR_SHOVEL_RAMP_EVENT_V] 
AS

	SELECT [s].shiftflag,
		   [s].siteflag,
		   [s].OPERATORID,
		   [s].Operator,
		   [s].OperatorImageURL,
		   [s].ShovelId,
		   ea.alarm_name,
    	   ea.alarm_start_time,
    	   ea.alarm_end_time
	FROM [SAF].[CONOPS_SAF_OPERATOR_SHOVEL_LIST_V] [s] WITH (NOLOCK)
	LEFT JOIN [dbo].[EQUIPMENT_ALARM] ea WITH (NOLOCK)
	ON [s].ShiftIndex = ea.SHIFTINDEX
	   AND [s].siteflag = ea.SITE_CODE
	   AND [s].ShovelId = ea.EQUIPMENT_ID
	WHERE ea.ALARM_NAME IS NOT NULL

