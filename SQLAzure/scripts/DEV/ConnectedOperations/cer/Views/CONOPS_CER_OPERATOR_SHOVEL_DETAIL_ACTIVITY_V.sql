CREATE VIEW [cer].[CONOPS_CER_OPERATOR_SHOVEL_DETAIL_ACTIVITY_V] AS




-- SELECT * FROM [CER].[CONOPS_CER_OPERATOR_SHOVEL_DETAIL_ACTIVITY_V] WITH (NOLOCK) WHERE ShiftFlag = 'PREV' OperatorId = '60030149'
CREATE VIEW [CER].[CONOPS_CER_OPERATOR_SHOVEL_DETAIL_ACTIVITY_V] 
AS

WITH OperatorAlerts AS (
    SELECT [ShiftFlag]
		,[SiteFlag]
		,[ShovelId]
		,[Reasons]
		,'Delay' AS AlertType
		,[StartDateTime] AS Generated 
    FROM [CER].[CONOPS_CER_OPERATOR_SHOVEL_DELAY_V] WITH (NOLOCK)
	UNION ALL
	SELECT [Shiftflag]
		,[Siteflag]
		,[ShovelId]
		,[alarm_name] AS Reasons
		,'Ramp Event' AS AlertType
		,[alarm_start_time] AS Generated 
    FROM [CER].[CONOPS_CER_OPERATOR_SHOVEL_RAMP_EVENT_V] WITH (NOLOCK)
	UNION ALL
	SELECT [shiftflag]
		,[siteflag]
		,[eqmtid] AS [ShovelId]
		,[ShiftState] AS Reasons
		,'Late Start' AS AlertType
		,[FirstLoginDateTime] AS Generated 
    FROM [CER].[CONOPS_CER_OPERATOR_HAS_LATE_START_V] WITH (NOLOCK)
)

SELECT [op].shiftflag
	,[op].Siteflag
	,[op].ShiftId
	,[op].ShiftIndex
	,[op].ShovelId
	,[op].Region
	,[op].OperatorId
	,[oa].AlertType
	,[oa].Reasons
	,[oa].Generated
FROM [CER].[CONOPS_CER_OPERATOR_SHOVEL_LIST_V] [op] WITH (NOLOCK) 
LEFT JOIN OperatorAlerts [oa]
	ON [op].ShiftFlag = [oa].ShiftFlag
	AND [op].ShovelId = [oa].ShovelId



