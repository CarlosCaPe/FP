CREATE VIEW [sie].[CONOPS_SIE_OPERATOR_TRUCK_ALERTS_V] AS






-- SELECT * FROM [sie].[CONOPS_SIE_OPERATOR_TRUCK_ALERTS_V] WITH (NOLOCK) WHERE Shiftflag = 'PREV'
CREATE VIEW [sie].[CONOPS_SIE_OPERATOR_TRUCK_ALERTS_V] 
AS

	WITH Alerts AS (
		SELECT ShiftIndex
			,SiteFlag
			,EqmtId AS [TruckId]
			,Operator_Id AS [OperatorId]
			,Alert_Type
			,Alert_Name
			,Alert_Description
			,Alert_Date
			,Alert_Generated_Datetime
		FROM [sie].[Alert] (NOLOCK)
	)

	SELECT [o].ShiftFlag
		,[o].SiteFlag
		,[o].OperatorId
		,[o].TruckId
		,[a].Alert_Type
		,[a].Alert_Name
		,[a].Alert_Description
		,[a].Alert_Generated_Datetime AS [GeratedDate]
	FROM [sie].[CONOPS_SIE_OPERATOR_TRUCK_V] [o] WITH (NOLOCK)
	LEFT JOIN Alerts [a]
	ON [o].TruckId = [a].TruckId
	   AND [o].ShiftIndex = [a].ShiftIndex
	WHERE [o].TruckId <> 'None' 
	AND [a].Alert_type IS NOT NULL

