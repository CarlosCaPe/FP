CREATE VIEW [SIE].[CONOPS_SIE_SHOVEL_TO_WATCH_V] AS


--select * from [sie].[CONOPS_SIE_SHOVEL_TO_WATCH_V] where shiftflag = 'prev'
CREATE VIEW [sie].[CONOPS_SIE_SHOVEL_TO_WATCH_V]
AS

WITH TONS AS (
	SELECT shiftid
		,shovelid
		,sum(totalmaterialmoved) AS tons
	FROM [sie].[CONOPS_SIE_SHIFT_OVERVIEW_V]
	GROUP BY shiftid
		,shovelid
	),
	
TGT AS (
	SELECT shiftid
		,shovelID
		,sum(shovelshifttarget) AS [target]
	FROM SIE.CONOPS_SIE_SHOVEL_SHIFT_TARGET_V
	GROUP BY shiftid
		,shovelID
	),
	
STAT AS (
	SELECT shiftid
		,eqmt
		,reasonidx
		,reasons
		,[status] AS eqmtcurrstatus
		,ROW_NUMBER() OVER (
			PARTITION BY shiftid
			,eqmt ORDER BY startdatetime DESC
			) num
	FROM [sie].[asset_efficiency] WITH (NOLOCK)
	WHERE unittype = 'shovel'
	)
	
SELECT a.shiftflag
	,a.siteflag
	,a.shiftid
	,a.shiftindex
	,a.shovelid
	,a.eqmttype
	,a.Operator
	,a.OperatorID
	,a.OperatorImageURL
	,tn.tons AS TotalMaterialMined
	,tg.target AS TotalMaterialMinedTarget
	,(tg.[target] - tn.tons) AS OffTarget
	,a.deltac
	,a.DeltaCTarget
	,a.idletime
	,a.idletimetarget
	,a.spotting
	,a.SpottingTarget
	,a.loading
	,a.LoadingTarget
	,a.dumping
	,a.dumpingtarget
	,a.payload
	,a.payloadTarget
	,a.NumberOfLoads
	,a.NumberOfLoadsTarget
	,a.TonsPerReadyHour
	,a.TonsPerReadyHourTarget
	,a.AssetEfficiency
	,a.AssetEfficiencyTarget
	,a.Availability
	,a.AvailabilityTarget
	,a.TotalMaterialMoved
	,a.TotalMaterialMovedTarget
	,a.HangTime
	,a.HangTimeTarget
	,st.reasonidx
	,st.reasons
	,st.eqmtcurrstatus
FROM TONS tn
LEFT JOIN TGT tg
	ON tn.shiftid = tg.shiftid
	AND tn.ShovelId = tg.ShovelId
LEFT JOIN [sie].[CONOPS_SIE_SHOVEL_POPUP] a WITH (NOLOCK)
	ON tn.shiftid = a.shiftid
	AND tn.ShovelId = a.ShovelID
LEFT JOIN STAT st
	ON a.shiftid = st.shiftid
	AND st.eqmt = a.ShovelID
	AND st.num = 1
WHERE (tg.[target] - tn.tons) > 0 

