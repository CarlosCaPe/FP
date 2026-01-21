CREATE VIEW [cer].[CONOPS_CER_OPERATOR_SHOVEL_DELAY_V] AS


-- SELECT * FROM [CER].[CONOPS_CER_OPERATOR_SHOVEL_DELAY_V] WITH (NOLOCK) WHERE Shiftflag = 'PREV'
CREATE VIEW [CER].[CONOPS_CER_OPERATOR_SHOVEL_DELAY_V] 
AS

	WITH DelayStatus AS (
		SELECT ShiftFlag,
			   Eqmt,
			   SUM(DURATION) AS Duration,
			   ReasonIdx,
			   Reasons,
			   MAX(StartDateTime) AS StartDateTime
		FROM [CER].[CONOPS_CER_SP_EQMT_STATUS_V] (NOLOCK)
		WHERE SiteFlag = 'CER'
			  AND [status] = 'Demora'
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
	FROM [CER].[CONOPS_CER_OPERATOR_SHOVEL_LIST_V] [o] WITH (NOLOCK)
	LEFT JOIN DelayStatus [d]
	ON [o].ShovelId = [d].Eqmt
	   AND [o].ShiftFlag = [d].ShiftFlag
	WHERE [o].ShovelId <> 'None' 
		  AND [d].REASONIDX IS NOT NULL

