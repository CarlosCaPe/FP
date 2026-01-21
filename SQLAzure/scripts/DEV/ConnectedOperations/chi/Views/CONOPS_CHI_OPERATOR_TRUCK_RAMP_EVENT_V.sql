CREATE VIEW [chi].[CONOPS_CHI_OPERATOR_TRUCK_RAMP_EVENT_V] AS



-- SELECT * FROM [chi].[CONOPS_CHI_OPERATOR_TRUCK_RAMP_EVENT_V] WITH (NOLOCK) WHERE Shiftflag = 'PREV'
CREATE VIEW [chi].[CONOPS_CHI_OPERATOR_TRUCK_RAMP_EVENT_V] 
AS

	SELECT [t].shiftflag,
		   [t].siteflag,
		   [t].OPERATORID,
		   [t].Operator,
		   [t].OperatorImageURL,
		   [t].TruckID,
		   ea.alarm_name,
    	   ea.alarm_start_time,
    	   ea.alarm_end_time
	FROM [chi].[CONOPS_CHI_OPERATOR_TRUCK_V] [t] WITH (NOLOCK)
	LEFT JOIN [dbo].[EQUIPMENT_ALARM] ea WITH (NOLOCK)
	ON [t].ShiftIndex = ea.SHIFTINDEX
	   AND [t].siteflag = ea.SITE_CODE
	   AND [t].TruckID = ea.EQUIPMENT_ID
	WHERE ea.ALARM_NAME IS NOT NULL

