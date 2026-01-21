CREATE VIEW [bag].[CONOPS_BAG_OPERATOR_TRUCK_DETAIL_ACTIVITY_V] AS







-- SELECT * FROM [bag].[CONOPS_BAG_OPERATOR_TRUCK_DETAIL_ACTIVITY_V] WITH (NOLOCK) WHERE ShiftFlag = 'PREV'
CREATE VIEW [bag].[CONOPS_BAG_OPERATOR_TRUCK_DETAIL_ACTIVITY_V] 
AS

WITH OperatorAlerts AS (
    SELECT [ShiftFlag]
		,[SiteFlag]
		,[TruckId]
		,'DELAY' AS [Alert_Type]
		,CONCAT('DELAY - ', [ReasonIdx]) AS [Alert_Name]
		,[Reasons] AS [Alert_Description]
		,[StartDateTime] AS [GeneratedDate]
    FROM [bag].[CONOPS_BAG_OPERATOR_TRUCK_DELAY_V] WITH (NOLOCK)
	UNION ALL
	SELECT [Shiftflag]
		,[Siteflag]
		,[TruckId]
		,'RAMP EVENT' AS Alert_Type
		,'RAMP EVENT' AS Alert_Name
		,[Alarm_Name] AS [Alert_Description]
		,[alarm_start_time] AS GeneratedDate 
    FROM [bag].[CONOPS_BAG_OPERATOR_TRUCK_RAMP_EVENT_V] WITH (NOLOCK)
	UNION ALL
	SELECT [shiftflag]
		,[siteflag]
		,[eqmtid] AS [TruckId]
		,'Late Start' AS [Alert_Type]
		,'Late Start' AS [Alert_Name]
		,[ShiftState] AS [Alert_Description]
		,[FirstLoginDateTime] AS GeneratedDate
    FROM [bag].[CONOPS_BAG_OPERATOR_HAS_LATE_START_V] WITH (NOLOCK)
	UNION ALL
	SELECT [shiftflag]
		,[siteflag]
		,[TruckId]
		,[Alert_type]
		,[Alert_Name]
		,[Alert_Description]
		,[GeratedDate] AS GeneratedDate
    FROM [bag].[CONOPS_BAG_OPERATOR_TRUCK_ALERTS_V] WITH (NOLOCK)
)

SELECT [op].shiftflag
	,[op].Siteflag
	,[op].Region
	,[op].OperatorId
	,[oa].[Alert_type]
	,[oa].[Alert_Name]
	,[oa].Alert_Description
	,[oa].GeneratedDate
FROM [bag].[CONOPS_BAG_OPERATOR_TRUCK_V] [op] WITH (NOLOCK) 
LEFT JOIN OperatorAlerts [oa]
	ON [op].ShiftFlag = [oa].ShiftFlag
	AND [op].TruckID = [oa].TruckID



