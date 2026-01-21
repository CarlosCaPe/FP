CREATE VIEW [ABR].[CONOPS_ABR_OPERATOR_DRILL_RAMP_EVENT_V] AS





-- SELECT * FROM [abr].[CONOPS_ABR_OPERATOR_DRILL_RAMP_EVENT_V] WITH (NOLOCK) WHERE Shiftflag = 'PREV'
CREATE VIEW [ABR].[CONOPS_ABR_OPERATOR_DRILL_RAMP_EVENT_V] 
AS

	SELECT dl.shiftflag,
		   dl.siteflag,
		   dl.OPERATORID,
		   dl.OperatorName,
		   dl.OperatorImageURL,
		   dl.DRILL_ID,
		   ea.alarm_name,
    	   ea.alarm_start_time,
    	   ea.alarm_end_time
	FROM [abr].[CONOPS_ABR_OPERATOR_DRILL_LIST_V] dl WITH (NOLOCK)
	LEFT JOIN [dbo].[EQUIPMENT_ALARM] ea WITH (NOLOCK)
	ON dl.ShiftIndex = ea.SHIFTINDEX
	   AND dl.siteflag = ea.SITE_CODE
	   AND dl.DRILL_ID = ea.EQUIPMENT_ID
	WHERE ea.ALARM_NAME IS NOT NULL


