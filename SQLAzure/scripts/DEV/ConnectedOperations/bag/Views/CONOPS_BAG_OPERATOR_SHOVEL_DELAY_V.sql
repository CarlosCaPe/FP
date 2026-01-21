CREATE VIEW [bag].[CONOPS_BAG_OPERATOR_SHOVEL_DELAY_V] AS


-- SELECT * FROM [BAG].[CONOPS_BAG_OPERATOR_SHOVEL_DELAY_V] WITH (NOLOCK) WHERE Shiftflag = 'PREV'
CREATE VIEW [bag].[CONOPS_BAG_OPERATOR_SHOVEL_DELAY_V] 
AS

	WITH DelayStatus AS (
		SELECT ShiftFlag,
			   Eqmt,
			   SUM(DURATION) AS Duration,
			   ReasonIdx,
			   Reasons,
			   MAX(StartDateTime) AS StartDateTime
		FROM [BAG].[CONOPS_BAG_SP_EQMT_STATUS_V] (NOLOCK)
		WHERE SiteFlag = 'BAG'
			  AND [status] = 'DELAY'
			  AND ReasonIdx <> '439'
		GROUP BY ShiftFlag, Eqmt, ReasonIdx, Reasons
	)

	SELECT [o].ShiftFlag,
		   [o].SiteFlag,
		   [o].OperatorId,
		   [o].ShovelId,
		   [d].ReasonIdx,
		   [d].Reasons,
		   [d].Duration,
		   [d].StartDateTime,
		   [o].Location
	FROM [BAG].[CONOPS_BAG_OPERATOR_SHOVEL_LIST_V] [o] WITH (NOLOCK)
	LEFT JOIN DelayStatus [d]
	ON [o].ShovelId = [d].Eqmt
	   AND [o].ShiftFlag = [d].ShiftFlag
	WHERE [o].ShovelId <> 'None' 
		  AND [d].REASONIDX IS NOT NULL

