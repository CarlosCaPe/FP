CREATE VIEW [cer].[CONOPS_CER_OPERATOR_SHOVEL_RAMP_EVENT_V] AS




-- SELECT * FROM [CER].[CONOPS_CER_OPERATOR_SHOVEL_RAMP_EVENT_V] WITH (NOLOCK) WHERE Shiftflag = 'PREV'
CREATE VIEW [CER].[CONOPS_CER_OPERATOR_SHOVEL_RAMP_EVENT_V] 
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
	FROM [CER].[CONOPS_CER_OPERATOR_SHOVEL_LIST_V] [s] WITH (NOLOCK)
	LEFT JOIN [dbo].[EQUIPMENT_ALARM] ea WITH (NOLOCK)
	ON [s].ShiftIndex = ea.SHIFTINDEX
	   AND [s].siteflag = ea.SITE_CODE
	   AND REPLACE([s].ShovelId, 'P', 'PALA') = ea.EQUIPMENT_ID
	WHERE ea.ALARM_NAME IS NOT NULL

