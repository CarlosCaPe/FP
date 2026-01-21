CREATE VIEW [ABR].[CONOPS_ABR_OPERATOR_TRUCK_DELAY_V] AS



-- SELECT * FROM [abr].[CONOPS_ABR_OPERATOR_TRUCK_DELAY_V] WITH (NOLOCK) WHERE Shiftflag = 'PREV'
CREATE VIEW [ABR].[CONOPS_ABR_OPERATOR_TRUCK_DELAY_V] 
AS

	WITH DelayStatus AS (
		SELECT ShiftFlag,
			   Eqmt,
			   SUM(DURATION) AS Duration,
			   ReasonIdx,
			   Reasons,
			   StartDateTime
		FROM [abr].[CONOPS_ABR_TP_EQMT_STATUS_V] (NOLOCK)
		WHERE [status] = 'Demora'
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
	FROM [abr].[CONOPS_ABR_OPERATOR_TRUCK_V] [o] WITH (NOLOCK)
	LEFT JOIN DelayStatus [d]
	ON [o].TruckId = [d].Eqmt
	   AND [o].ShiftFlag = [d].ShiftFlag
	WHERE [o].TruckId <> 'None' 
		  AND [d].REASONIDX IS NOT NULL


