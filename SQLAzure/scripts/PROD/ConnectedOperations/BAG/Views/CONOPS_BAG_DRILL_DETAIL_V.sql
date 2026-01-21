CREATE VIEW [BAG].[CONOPS_BAG_DRILL_DETAIL_V] AS

--SELECT * FROM [bag].[CONOPS_BAG_DRILL_DETAIL_V] WITH (NOLOCK) WHERE [shiftflag] = 'CURR' ORDER BY [DRILL_ID]    
CREATE VIEW [bag].[CONOPS_BAG_DRILL_DETAIL_V]    
AS

WITH EqmtStatus AS (
	SELECT SHIFTINDEX
		,site_code
		,Drill_ID AS eqmt
		,MODEL
		,startdatetime
		,enddatetime
		,[status] AS eqmtcurrstatus
		,reasonidx
		,reason AS reasons
		,[Duration]
		,ROW_NUMBER() OVER (PARTITION BY SHIFTINDEX, Drill_ID ORDER BY startdatetime DESC) num
	FROM [bag].[drill_asset_efficiency_v] WITH (NOLOCK)
),

OperatorDetail AS (
	SELECT 
		SHIFTINDEX,
		REPLACE(EquipmentID, '-','') AS DRILL_ID,
		RIGHT('0000000000' + OperatorId, 10) AS OperatorId,
		Operator AS OperatorName,
		CrewName AS Crew
	FROM bag.fleet_pit_machine_c WITH(NOLOCK)
	WHERE EquipmentCategory = 'Track Drill'
),

LatestPatternNo AS (
	SELECT [ds].SHIFTINDEX
		,[ds].[SITE_CODE]
		,REPLACE(DRILL_ID, ' ', '') AS DRILL_ID
		,[ds].PATTERN_NO
		,ROW_NUMBER() OVER (PARTITION BY [ds].SHIFTINDEX, [ds].SITE_CODE, Drill_ID ORDER BY END_HOLE_TS DESC) num
	FROM [dbo].[FR_DRILLING_SCORES] [ds] WITH (NOLOCK)
	WHERE DRILL_ID IS NOT NULL
		AND [ds].[SITE_CODE] = 'BAG'
)

SELECT ae.[shiftflag]
	,ae.[siteflag]
	,ae.[ShiftIndex]
	,ae.[ShiftId]
	,[ae].Equipment AS [DRILL_ID]
	,[o].OPERATORID
	,CASE 
		WHEN OperatorId IS NULL
			OR OperatorId = - 1
			THEN NULL
		ELSE CONCAT ([img].Value, RIGHT('0000000000' + OperatorId, 10), '.jpg')
		END AS OperatorImageURL
	,[o].OperatorName
	,[o].CREW
	,[lp].PATTERN_NO
	,[es].MODEL
	,[es].eqmtcurrstatus
	,[es].reasonidx
	,[es].reasons
	,[es].[Duration]
	,[Holes_Drilled]
	,15 [Hole_Drilled_Target]
	,[Feet_Drilled]
	,550 AS [Feet_Drilled_Target]
	,[Avail]
	,[DRILLAVAILABILITY]
	,CASE 
		WHEN [ae].Avail IS NULL
			OR [ae].Avail = 0
			THEN 0
		ELSE ([ae].AE / [ae].Avail) * 100
		END AS UofA
	,[DRILLUTILIZATION]
	,[ae].AE AS AssetEfficiency
	,DRILLASSETEFFICIENCY AS AssetEfficiencyTarget
	,[Average_Pen_Rate]
	,230 AS PenetrationRateTarget
	,[Total_Depth]
	,[Depth_Drill_Score]
	,[Over_Drill]
	,[Under_Drill]
	,[Average_HoleTime]
	,[Average_GPS_Quality]
	,[Avg_Time_Between_Holes]
	,[Average_First_Last_Drill]
	,[Average_First_Drill]
	,[Average_Last_Drill]
	,[XY_Drill_Score]
	,[OVERALLSCORE]
FROM [bag].[CONOPS_BAG_DB_DRILL_ASSET_EFFICIENCY_PER_DRILL_V] [ae] WITH (NOLOCK)
LEFT JOIN [bag].[CONOPS_BAG_DB_DRILL_SCORE_V] [ds] WITH (NOLOCK)
	ON [ae].shiftflag = [ds].shiftflag
	AND [ae].siteflag = [ds].siteflag
	AND [ds].DRILL_ID = [ae].Equipment
LEFT JOIN [bag].[CONOPS_BAG_DB_DRILL_SCORE_TARGET_V] [t] WITH (NOLOCK)
	ON LEFT([ae].shiftid, 4) = [t].ShiftId
	AND [ae].siteflag = [t].siteflag
LEFT JOIN EqmtStatus [es]
	ON [es].eqmt = [ae].Equipment
	AND [es].num = 1
	AND [es].SHIFTINDEX = [ae].ShiftIndex
	AND [ae].siteflag = [es].site_code
LEFT JOIN OperatorDetail [o] 
	ON [o].DRILL_ID = [ae].Equipment
	AND [o].SHIFTINDEX = [ae].ShiftIndex
LEFT JOIN LatestPatternNo [lp]
	ON [ae].Equipment = [lp].DRILL_ID
	AND [ae].SHIFTINDEX = [lp].SHIFTINDEX
	AND [lp].num = 1
LEFT JOIN dbo.LOOKUPS [img] WITH (NOLOCK)
	ON [img].TableType = 'CONF'
	AND [img].TableCode = 'IMGURL'

