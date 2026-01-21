CREATE VIEW [ABR].[CONOPS_ABR_OPERATOR_SHOVEL_RAMP_EVENT_V] AS


-- SELECT * FROM [abr].[CONOPS_ABR_OPERATOR_SHOVEL_RAMP_EVENT_V] WITH (NOLOCK) WHERE Shiftflag = 'PREV'
CREATE VIEW [ABR].[CONOPS_ABR_OPERATOR_SHOVEL_RAMP_EVENT_V] 
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
	FROM [abr].[CONOPS_ABR_OPERATOR_SHOVEL_LIST_V] [s] WITH (NOLOCK)
	LEFT JOIN [dbo].[EQUIPMENT_ALARM] ea WITH (NOLOCK)
	ON [s].ShiftIndex = ea.SHIFTINDEX
	   AND [s].siteflag = ea.SITE_CODE
	   AND [s].ShovelId = CONCAT(LEFT(EQUIPMENT_ID,1),SUBSTRING(SUBSTRING(EQUIPMENT_ID, 2, LEN(EQUIPMENT_ID) -1), patindex('%[^0]%',SUBSTRING(EQUIPMENT_ID, 2, LEN(EQUIPMENT_ID) -1)), 10))
	WHERE ea.ALARM_NAME IS NOT NULL

