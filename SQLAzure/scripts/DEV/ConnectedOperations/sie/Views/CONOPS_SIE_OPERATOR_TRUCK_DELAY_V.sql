CREATE VIEW [sie].[CONOPS_SIE_OPERATOR_TRUCK_DELAY_V] AS




-- SELECT * FROM [sie].[CONOPS_SIE_OPERATOR_TRUCK_DELAY_V] WITH (NOLOCK) WHERE Shiftflag = 'PREV'
CREATE VIEW [sie].[CONOPS_SIE_OPERATOR_TRUCK_DELAY_V] 
AS

	WITH DelayStatus AS (
		SELECT ShiftFlag,
			   Eqmt,
			   SUM(DURATION) AS Duration,
			   ReasonIdx,
			   Reasons,
			   StartDateTime
		FROM [sie].[CONOPS_SIE_TP_EQMT_STATUS_V] (NOLOCK)
		WHERE SiteFlag = 'SIE'
			  AND [status] = 'DELAY'
			  AND ReasonIdx <> '439'
		GROUP BY ShiftFlag, Eqmt, ReasonIdx, Reasons, StartDateTime
	)

	SELECT [o].ShiftFlag,
		   [o].SiteFlag,
		   [o].OperatorId,
		   [o].TruckId,
		   [d].ReasonIdx,
		   [d].Reasons,
		   [d].Duration,
		   [d].StartDateTime
	FROM [sie].[CONOPS_SIE_OPERATOR_TRUCK_V] [o] WITH (NOLOCK)
	LEFT JOIN DelayStatus [d]
	ON [o].TruckId = [d].Eqmt
	   AND [o].ShiftFlag = [d].ShiftFlag
	WHERE [o].TruckId <> 'None' 
		  AND [d].REASONIDX IS NOT NULL

