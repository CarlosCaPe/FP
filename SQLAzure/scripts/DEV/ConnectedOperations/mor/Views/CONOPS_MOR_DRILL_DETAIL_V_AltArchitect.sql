CREATE VIEW [mor].[CONOPS_MOR_DRILL_DETAIL_V_AltArchitect] AS



-- SELECT * FROM [mor].[CONOPS_MOR_DRILL_DETAIL_V] WITH (NOLOCK) WHERE [shiftflag] = 'CURR' ORDER BY [DRILL_ID]
CREATE   VIEW [mor].[CONOPS_MOR_DRILL_DETAIL_V_AltArchitect]
AS

WITH EqmtStatus AS (
	SELECT SHIFTINDEX,
		   site_code,
		   Drill_ID AS eqmt,
		   MODEL,
		   startdatetime,
		   enddatetime,
		   [status] AS eqmtcurrstatus,
		   reasonidx,
		   reason AS reasons,
		   [Duration],
		   ROW_NUMBER() OVER (PARTITION BY SHIFTINDEX, Drill_ID
							  ORDER BY startdatetime DESC) num
	FROM [mor].[drill_asset_efficiency_v_AltArchitect] WITH (NOLOCK)
),

OperatorDetail AS (
	SELECT [ds].SHIFTINDEX,
	       [ds].[SITE_CODE],
		   REPLACE(DRILL_ID, ' ','') AS DRILL_ID,
		   OPERATORID,
		   [w].FIRST_LAST_NAME AS OperatorName,
		   ROW_NUMBER() OVER (PARTITION BY [ds].SHIFTINDEX, [ds].SITE_CODE, Drill_ID
						      ORDER BY END_HOLE_TS DESC) num
	FROM	[dbo].[FR_DRILLING_SCORES] [ds] WITH (NOLOCK)
	LEFT JOIN 
			[dbo].[operator_personnel_map] [w] WITH (NOLOCK)
		ON 
			w.[OperatorID_Num] = ds.[OperatorID_Num]
		AND 
			[w].SHIFTINDEX = [ds].SHIFTINDEX
		AND 
			[ds].SITE_CODE = [w].SITE_CODE
	WHERE	DRILL_ID IS NOT NULL 
		AND
			[ds].[OPERATORID] IS NOT NULL
		AND 
			[ds].[SITE_CODE] = 'MOR'
)

SELECT ae.[shiftflag] ,
       ae.[siteflag] ,
	   ae.[ShiftIndex],
	   [ae].Equipment AS [DRILL_ID],
	   [o].OPERATORID,
	   CASE WHEN [OperatorId] IS NULL OR [OperatorId] = -1 THEN NULL
			ELSE concat('https://images.services.fmi.com/publishedimages/',
				   RIGHT('0000000000' + [o].OPERATORID, 10),'.jpg') END as OperatorImageURL,
	   [o].OperatorName,
	   [es].MODEL,
	   [es].eqmtcurrstatus,
	   [es].reasonidx,
	   [es].reasons,
	   [es].[Duration],
	   [Holes_Drilled] ,
       0 AS [Hole_Drilled_Target] ,
       [Feet_Drilled] ,
       0 AS [Feet_Drilled_Target] ,
       [Avail] ,
       0 AS [DRILLAVAILABILITY] ,
       [UofA] ,
       0 AS [DRILLUTILIZATION] ,
       [Average_Pen_Rate] ,
       [Total_Depth] ,
       [Over_Drill] ,
       [Under_Drill] ,
	   [Average_HoleTime] ,
       [Average_GPS_Quality] ,
       [Avg_Time_Between_Holes] ,
       [Average_First_Last_Drill],
	   [XY_Drill_Score]
FROM [mor].[CONOPS_MOR_DB_DRILL_ASSET_EFFICIENCY_PER_DRILL_V] [ae] WITH (NOLOCK)
LEFT JOIN [dbo].[CONOPS_DB_DRILL_SCORES_V] [ds] WITH (NOLOCK)
ON [ae].shiftflag = [ds].shiftflag AND [ae].siteflag = [ds].siteflag
AND [ds].DRILL_ID = [ae].Equipment
--LEFT JOIN [mor].[CONOPS_MOR_DB_DRILL_SCORE_TARGET_V] [t] WITH (NOLOCK)
--ON LEFT([ae].shiftid, 4) = [t].ShiftId AND [ae].siteflag = [t].siteflag
LEFT JOIN EqmtStatus [es]
ON [es].eqmt = [ae].Equipment and [es].num = 1
   AND [es].SHIFTINDEX = [ae].ShiftIndex AND [ae].siteflag = [es].site_code
LEFT JOIN OperatorDetail [o]
ON [o].DRILL_ID = [ae].Equipment and [o].num = 1
   AND [o].SHIFTINDEX = [ae].ShiftIndex AND [ae].siteflag = [o].[SITE_CODE]

